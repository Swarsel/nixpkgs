{
  config,
  lib,
  pkgs,
  options,
  buildEnv,
  ...
}:

with lib;

let
  defaultUser = "healthchecks";
  cfg = config.services.healthchecks;
  opt = options.services.healthchecks;
  pkg = cfg.package;
  boolToPython = b: if b then "True" else "False";
  environment = {
    PYTHONPATH = pkg.pythonPath;
    STATIC_ROOT = cfg.dataDir + "/static";
  }
  // lib.filterAttrs (_: v: !isNull v) cfg.settings;

  environmentFile = pkgs.writeText "healthchecks-environment" (
    lib.generators.toKeyValue { } environment
  );

  healthchecksManageScript = pkgs.writeShellScriptBin "healthchecks-manage" ''
    sudo=exec
    if [[ "$USER" != "${cfg.user}" ]]; then
      sudo='exec /run/wrappers/bin/sudo -u ${cfg.user} --preserve-env --preserve-env=PYTHONPATH'
    fi
    export $(cat ${environmentFile} | xargs)
    ${lib.optionalString (cfg.settingsFile != null) "export $(cat ${cfg.settingsFile} | xargs)"}
    $sudo ${pkg}/opt/healthchecks/manage.py "$@"
  '';
in
{
  options.services.healthchecks = {
    enable = mkEnableOption "healthchecks" // {
      description = ''
        Enable healthchecks.
        It is expected to be run behind a HTTP reverse proxy.
      '';
    };

    package = mkPackageOption pkgs "healthchecks" { };

    dataDir = mkOption {
      default = "/var/lib/healthchecks";

      description = ''
        The directory used to store all data for healthchecks.

        ::: {.note}
        If left as the default value this directory will automatically be created before
        the healthchecks server starts, otherwise you are responsible for ensuring the
        directory exists with appropriate ownership and permissions.
        :::
      '';

      type = types.str;
    };

    group = mkOption {
      default = defaultUser;

      description = ''
        Group account under which healthchecks runs.

        ::: {.note}
        If left as the default value this group will automatically be created
        on system activation, otherwise you are responsible for
        ensuring the group exists before the healthchecks service starts.
        :::
      '';

      type = types.str;
    };

    listenAddress = mkOption {
      default = "localhost";
      description = "Address the server will listen on.";
      type = types.str;
    };

    port = mkOption {
      default = 8000;
      description = "Port the server will listen on.";
      type = types.port;
    };

    settings = lib.mkOption {
      description = ''
        Environment variables which are read by healthchecks `(local)_settings.py`.

        Settings which are explicitly covered in options below, are type-checked and/or transformed
        before added to the environment, everything else is passed as a string.

        See <https://healthchecks.io/docs/self_hosted_configuration/>
        for a full documentation of settings.

        We add additional variables to this list inside the packages `local_settings.py.`
        - `STATIC_ROOT` to set a state directory for dynamically generated static files.
        - `SECRET_KEY_FILE` to read `SECRET_KEY` from a file at runtime and keep it out of
          /nix/store.
        - `_FILE` variants for several values that hold sensitive information in
          [Healthchecks configuration](https://healthchecks.io/docs/self_hosted_configuration/) so
          that they also can be read from a file and kept out of /nix/store. To see which values
          have support for a `_FILE` variant, run:
          - `nix-instantiate --eval --expr '(import <nixpkgs> {}).healthchecks.secrets'`
          - or `nix eval 'nixpkgs#healthchecks.secrets'` if the flake support has been enabled.

        If the same variable is set in both `settings` and `settingsFile` the value from `settingsFile` has priority.
      '';

      type = types.submodule (settings: {
        options = {
          ALLOWED_HOSTS = lib.mkOption {
            apply = lib.concatStringsSep ",";
            default = [ "*" ];
            description = "The host/domain names that this site can serve.";
            type = types.listOf types.str;
          };

          DB = mkOption {
            default = "sqlite";
            description = "Database engine to use.";

            type = types.enum [
              "sqlite"
              "postgres"
              "mysql"
            ];
          };

          DB_NAME = mkOption {
            default = if settings.config.DB == "sqlite" then "${cfg.dataDir}/healthchecks.sqlite" else "hc";

            defaultText = lib.literalExpression ''
              if config.${settings.options.DB} == "sqlite"
              then "''${config.${opt.dataDir}}/healthchecks.sqlite"
              else "hc"
            '';

            description = "Database name.";
            type = types.str;
          };

          DEBUG = mkOption {
            apply = boolToPython;
            default = false;
            description = "Enable debug mode.";
            type = types.bool;
          };

          REGISTRATION_OPEN = mkOption {
            apply = boolToPython;
            default = false;

            description = ''
              A boolean that controls whether site visitors can create new accounts.
              Set it to false if you are setting up a private Healthchecks instance,
              but it needs to be publicly accessible (so, for example, your cloud
              services can send pings to it).
              If you close new user registration, you can still selectively invite
              users to your team account.
            '';

            type = types.bool;
          };

          SECRET_KEY_FILE = mkOption {
            default = null;
            description = "Path to a file containing the secret key.";
            type = types.nullOr types.path;
          };
        };

        freeformType = types.attrsOf types.str;
      });
    };

    settingsFile = lib.mkOption {
      default = null;
      description = opt.settings.description;
      type = lib.types.nullOr lib.types.path;
    };

    user = mkOption {
      default = defaultUser;

      description = ''
        User account under which healthchecks runs.

        ::: {.note}
        If left as the default value this user will automatically be created
        on system activation, otherwise you are responsible for
        ensuring the user exists before the healthchecks service starts.
        :::
      '';

      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ healthchecksManageScript ];

    systemd.services =
      let
        commonConfig = {
          EnvironmentFile = [
            environmentFile
          ]
          ++ lib.optional (cfg.settingsFile != null) cfg.settingsFile;

          Group = cfg.group;
          StateDirectory = mkIf (cfg.dataDir == "/var/lib/healthchecks") "healthchecks";
          StateDirectoryMode = mkIf (cfg.dataDir == "/var/lib/healthchecks") "0750";
          User = cfg.user;
          WorkingDirectory = cfg.dataDir;
        };
      in
      {
        healthchecks = {
          after = [ "healthchecks-migration.service" ];
          description = "Healthchecks WSGI Service";

          preStart = ''
            ${pkg}/opt/healthchecks/manage.py collectstatic --no-input
            ${pkg}/opt/healthchecks/manage.py remove_stale_contenttypes --no-input
          ''
          + lib.optionalString (cfg.settings.DEBUG != "True") "${pkg}/opt/healthchecks/manage.py compress";

          serviceConfig = commonConfig // {
            ExecStart = ''
              ${pkgs.python3Packages.gunicorn}/bin/gunicorn hc.wsgi \
                --bind ${cfg.listenAddress}:${toString cfg.port} \
                --pythonpath ${pkg}/opt/healthchecks
            '';

            Restart = "always";
          };

          wantedBy = [ "healthchecks.target" ];
        };

        healthchecks-migration = {
          description = "Healthchecks migrations";

          serviceConfig = commonConfig // {
            ExecStart = ''
              ${pkg}/opt/healthchecks/manage.py migrate
            '';

            Restart = "on-failure";
            Type = "oneshot";
          };

          wantedBy = [ "healthchecks.target" ];
        };

        healthchecks-sendalerts = {
          after = [ "healthchecks.service" ];
          description = "Healthchecks Alert Service";

          serviceConfig = commonConfig // {
            ExecStart = ''
              ${pkg}/opt/healthchecks/manage.py sendalerts
            '';

            Restart = "always";
          };

          wantedBy = [ "healthchecks.target" ];
        };

        healthchecks-sendreports = {
          after = [ "healthchecks.service" ];
          description = "Healthchecks Reporting Service";

          serviceConfig = commonConfig // {
            ExecStart = ''
              ${pkg}/opt/healthchecks/manage.py sendreports --loop
            '';

            Restart = "always";
          };

          wantedBy = [ "healthchecks.target" ];
        };
      };

    systemd.targets.healthchecks = {
      after = [
        "network.target"
        "network-online.target"
      ];

      description = "Target for all Healthchecks services";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    users.groups = optionalAttrs (cfg.user == defaultUser) {
      ${defaultUser} = {
        members = [ defaultUser ];
      };
    };

    users.users = optionalAttrs (cfg.user == defaultUser) {
      ${defaultUser} = {
        description = "healthchecks service owner";
        group = defaultUser;
        isSystemUser = true;
      };
    };
  };
}
