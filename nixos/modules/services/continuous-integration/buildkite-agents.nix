{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.buildkite-agents;

  hooksDir =
    hooks:
    let
      mkHookEntry = name: text: ''
        ln --symbolic ${pkgs.writeShellApplication { inherit name text; }}/bin/${name} $out/${name}
      '';
    in
    pkgs.runCommand "buildkite-agent-hooks"
      {
        preferLocalBuild = true;
      }
      ''
        mkdir $out
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList mkHookEntry hooks)}
      '';

  buildkiteOptions =
    {
      config,
      name ? "",
      ...
    }:
    {
      options = {
        enable = lib.mkOption {
          default = true;
          description = "Whether to enable this buildkite agent";
          type = lib.types.bool;
        };

        package = lib.mkPackageOption pkgs "buildkite-agent" { };

        dataDir = lib.mkOption {
          default = "/var/lib/buildkite-agent-${name}";
          description = "The workdir for the agent";
          type = lib.types.str;
        };

        extraConfig = lib.mkOption {
          default = "";

          description = ''
            Extra lines to be added verbatim to the configuration file.
          '';

          example = "debug=true";
          type = lib.types.lines;
        };

        extraGroups = lib.mkOption {
          default = [ "keys" ];
          description = "Groups the user for this buildkite agent should belong to";
          type = lib.types.listOf lib.types.str;
        };

        hooks = lib.mkOption {
          default = { };

          description = ''
            "Agent" hooks to install.
            See <https://buildkite.com/docs/agent/v3/hooks> for possible options.
          '';

          example = lib.literalExpression ''
            {
              environment = '''
                export SECRET_VAR=`head -1 /run/keys/secret`
              ''';
            }'';

          type = lib.types.attrsOf lib.types.lines;
        };

        hooksPath = lib.mkOption {
          default = hooksDir config.hooks;
          defaultText = lib.literalMD "generated from {option}`services.buildkite-agents.<name>.hooks`";

          description = ''
            Path to the directory storing the hooks.
            Consider using {option}`services.buildkite-agents.<name>.hooks.<name>`
            instead.
          '';

          type = lib.types.path;
        };

        name = lib.mkOption {
          default = "%hostname-${name}-%n";

          description = ''
            The name of the agent as seen in the buildkite dashboard.
          '';

          type = lib.types.str;
        };

        privateSshKeyPath = lib.mkOption {
          ## maximum care is taken so that secrets (ssh keys and the CI token)
          ## don't end up in the Nix store.
          apply = final: if final == null then null else toString final;
          default = null;

          description = ''
            OpenSSH private key

            A run-time path to the key file, which is supposed to be provisioned
            outside of Nix store.
          '';

          type = lib.types.nullOr lib.types.path;
        };

        runtimePackages = lib.mkOption {
          default = [
            pkgs.bash
            pkgs.gnutar
            pkgs.gzip
            pkgs.git
            pkgs.nix
          ];

          defaultText = lib.literalExpression "[ pkgs.bash pkgs.gnutar pkgs.gzip pkgs.git pkgs.nix ]";
          description = "Add programs to the buildkite-agent environment";
          type = lib.types.listOf lib.types.package;
        };

        shell = lib.mkOption {
          default = "${pkgs.bash}/bin/bash -e -c";
          defaultText = lib.literalExpression ''"''${pkgs.bash}/bin/bash -e -c"'';

          description = ''
            Command that buildkite-agent 3 will execute when it spawns a shell.
          '';

          type = lib.types.str;
        };

        tags = lib.mkOption {
          default = { };

          description = ''
            Tags for the agent.
          '';

          example = {
            docker = "true";
            queue = "default";
            ruby2 = "true";
          };

          type = lib.types.attrsOf (lib.types.either lib.types.str (lib.types.listOf lib.types.str));
        };

        tokenPath = lib.mkOption {
          description = ''
            The token from your Buildkite "Agents" page.

            A run-time path to the token file, which is supposed to be provisioned
            outside of Nix store.
          '';

          type = lib.types.path;
        };
      };
    };
  enabledAgents = lib.filterAttrs (n: v: v.enable) cfg;
  mapAgents = function: lib.mkMerge (lib.mapAttrsToList function enabledAgents);
in
{
  options.services.buildkite-agents = lib.mkOption {
    default = { };

    description = ''
      Attribute set of buildkite agents.
      The attribute key is combined with the hostname and a unique integer to
      create the final agent name. This can be overridden by setting the `name`
      attribute.
    '';

    type = lib.types.attrsOf (lib.types.submodule buildkiteOptions);
  };

  config.assertions = mapAgents (
    name: cfg: [
      {
        assertion = cfg.hooksPath != hooksDir cfg.hooks -> cfg.hooks == { };

        message = ''
          Options `services.buildkite-agents.${name}.hooksPath' and
          `services.buildkite-agents.${name}.hooks.<name>' are mutually exclusive.
        '';
      }
    ]
  );

  config.systemd.services = mapAgents (
    name: cfg: {
      "buildkite-agent-${name}" = {
        after = [ "network.target" ];
        description = "Buildkite Agent";

        environment = config.networking.proxy.envVars // {
          HOME = cfg.dataDir;
          NIX_REMOTE = "daemon";
        };

        path = cfg.runtimePackages ++ [
          cfg.package
          pkgs.coreutils
        ];

        ## NB: maximum care is taken so that secrets (ssh keys and the CI token)
        ##     don't end up in the Nix store.
        preStart =
          let
            sshDir = "${cfg.dataDir}/.ssh";
            tagStr =
              name: value:
              if lib.isList value then
                lib.concatStringsSep "," (map (v: "${name}=${v}") value)
              else
                "${name}=${value}";
            tagsStr = lib.concatStringsSep "," (lib.mapAttrsToList tagStr cfg.tags);
          in
          lib.optionalString (cfg.privateSshKeyPath != null) ''
            mkdir -m 0700 -p "${sshDir}"
            install -m600 "${toString cfg.privateSshKeyPath}" "${sshDir}/id_rsa"
          ''
          + ''
            cat > "${cfg.dataDir}/buildkite-agent.cfg" <<EOF
            token="$(cat ${toString cfg.tokenPath})"
            name="${cfg.name}"
            shell="${cfg.shell}"
            tags="${tagsStr}"
            build-path="${cfg.dataDir}/builds"
            hooks-path="${cfg.hooksPath}"
            ${cfg.extraConfig}
            EOF
          '';

        serviceConfig = {
          ExecStart = "${cfg.package}/bin/buildkite-agent start --config ${cfg.dataDir}/buildkite-agent.cfg";
          KillMode = "mixed";
          Restart = "on-failure";
          RestartSec = 5;
          TimeoutSec = 10;
          # set a long timeout to give buildkite-agent a chance to finish current builds
          TimeoutStopSec = "2 min";
          User = "buildkite-agent-${name}";
        };

        wantedBy = [ "multi-user.target" ];
      };
    }
  );

  config.users.groups = mapAgents (
    name: cfg: {
      "buildkite-agent-${name}" = { };
    }
  );

  config.users.users = mapAgents (
    name: cfg: {
      "buildkite-agent-${name}" = {
        createHome = true;
        description = "Buildkite agent user";
        extraGroups = cfg.extraGroups;
        group = "buildkite-agent-${name}";
        home = cfg.dataDir;
        isSystemUser = true;
        name = "buildkite-agent-${name}";
      };
    }
  );
}
