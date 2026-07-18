{
  config,
  lib,
  pkgs,
  ...
}:
let
  format = pkgs.formats.json { };
  commonOptions =
    {
      pkgName,
      flavour ? pkgName,
    }:
    lib.mkOption {
      default = { };

      description = ''
        Attribute set of ${flavour} instances.
        Creates independent `${flavour}-''${name}.service` systemd units for each instance defined here.
      '';

      type =
        with lib.types;
        attrsOf (
          submodule (
            { name, ... }:
            {
              options = {
                enable = lib.mkEnableOption "this ${flavour} instance" // {
                  default = true;
                };

                package = lib.mkPackageOption pkgs pkgName { };

                group = lib.mkOption {
                  default = "root";

                  description = ''
                    Group under which this instance runs.
                  '';

                  type = types.str;
                };

                settings = lib.mkOption {
                  default = { };

                  description =
                    let
                      upstreamDocs =
                        if flavour == "vault-agent" then
                          "https://developer.hashicorp.com/vault/docs/agent#configuration-file-options"
                        else
                          "https://github.com/hashicorp/consul-template/blob/main/docs/configuration.md#configuration-file";
                    in
                    ''
                      Free-form settings written directly to the {file}`config.json` file.
                      Refer to <${upstreamDocs}> for supported values.

                      ::: {.note}
                      Resulting format is JSON not HCL.
                      Refer to <https://www.hcl2json.com/> if you are unsure how to convert HCL options to JSON.
                      :::
                    '';

                  type = types.submodule {
                    options = {
                      pid_file = lib.mkOption {
                        default = "/run/${flavour}/${name}.pid";

                        description = ''
                          Path to use for the pid file.
                        '';

                        type = types.str;
                      };
                    };

                    freeformType = format.type;
                  };
                };

                user = lib.mkOption {
                  default = "root";

                  description = ''
                    User under which this instance runs.
                  '';

                  type = types.str;
                };
              };
            }
          )
        );
    };

  createAgentInstance =
    {
      flavour,
      instance,
      name,
    }:
    let
      configFile = format.generate "${name}.json" instance.settings;
    in
    lib.mkIf (instance.enable) {
      after = [ "network.target" ];
      description = "${flavour} daemon - ${name}";
      path = [ pkgs.getent ];

      serviceConfig = {
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGHUP $MAINPID";

        ExecStart = "${lib.getExe instance.package} ${
          lib.optionalString (flavour == "vault-agent") "agent"
        } -config ${configFile}";

        Group = instance.group;
        KillSignal = "SIGINT";
        Restart = "on-failure";
        RuntimeDirectory = flavour;
        TimeoutStopSec = "30s";
        User = instance.user;
      };

      startLimitBurst = 3;
      startLimitIntervalSec = 60;
      wantedBy = [ "multi-user.target" ];
    };
in
{
  options = {
    services.consul-template.instances = commonOptions { pkgName = "consul-template"; };

    services.vault-agent.instances = commonOptions {
      flavour = "vault-agent";
      pkgName = "vault";
    };
  };

  config = lib.mkMerge (
    map
      (
        flavour:
        let
          cfg = config.services.${flavour};
        in
        lib.mkIf (cfg.instances != { }) {
          systemd.services = lib.mapAttrs' (
            name: instance:
            lib.nameValuePair "${flavour}-${name}" (createAgentInstance {
              inherit name instance flavour;
            })
          ) cfg.instances;
        }
      )
      [
        "consul-template"
        "vault-agent"
      ]
  );

  meta.maintainers = with lib.maintainers; [
    emilylange
    tcheronneau
  ];
}
