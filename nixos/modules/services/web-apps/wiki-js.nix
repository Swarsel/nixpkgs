{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.wiki-js;

  format = pkgs.formats.json { };

  configFile = format.generate "wiki-js.yml" cfg.settings;
in
{
  options.services.wiki-js = {
    enable = mkEnableOption "wiki-js";

    environmentFile = mkOption {
      default = null;

      description = ''
        Environment file to inject e.g. secrets into the configuration.
      '';

      example = "/root/wiki-js.env";
      type = types.nullOr types.path;
    };

    settings = mkOption {
      default = { };

      description = ''
        Settings to configure `wiki-js`. This directly
        corresponds to [the upstream configuration options](https://docs.requarks.io/install/config).

        Secrets can be injected via the environment by
        - specifying [](#opt-services.wiki-js.environmentFile)
          to contain secrets
        - and setting sensitive values to `$(ENVIRONMENT_VAR)`
          with this value defined in the environment-file.
      '';

      type = types.submodule {
        options = {
          bindIP = mkOption {
            default = "0.0.0.0";

            description = ''
              IPs the service should listen to.
            '';

            type = types.str;
          };

          db = {
            db = mkOption {
              default = "wiki";

              description = ''
                Name of the database to use.
              '';

              type = types.str;
            };

            host = mkOption {
              description = ''
                Hostname or socket-path to connect to.
              '';

              example = "/run/postgresql";
              type = types.str;
            };

            type = mkOption {
              default = "postgres";

              description = ''
                Database driver to use for persistence. Please note that `sqlite`
                is currently not supported as the build process for it is currently not implemented
                in `pkgs.wiki-js` and it's not recommended by upstream for
                production use.
              '';

              type = types.enum [
                "postgres"
                "mysql"
                "mariadb"
                "mssql"
              ];
            };
          };

          logLevel = mkOption {
            default = "info";

            description = ''
              Define how much detail is supposed to be logged at runtime.
            '';

            type = types.enum [
              "error"
              "warn"
              "info"
              "verbose"
              "debug"
              "silly"
            ];
          };

          offline = mkEnableOption "offline mode" // {
            description = ''
              Disable latest file updates and enable
              [sideloading](https://docs.requarks.io/install/sideload).
            '';
          };

          port = mkOption {
            default = 3000;

            description = ''
              TCP port the process should listen to.
            '';

            type = types.port;
          };
        };

        freeformType = format.type;
      };
    };

    stateDirectoryName = mkOption {
      default = "wiki-js";

      description = ''
        Name of the directory in {file}`/var/lib`.
      '';

      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    services.wiki-js.settings.dataPath = "/var/lib/${cfg.stateDirectoryName}";

    systemd.services.wiki-js = {
      description = "A modern and powerful wiki app built on Node.js";
      documentation = [ "https://docs.requarks.io/" ];

      path = with pkgs; [
        # Needed for git storage.
        git
        # Needed for git+ssh storage.
        openssh
      ];

      preStart = ''
        ln -sf ${configFile} /var/lib/${cfg.stateDirectoryName}/config.yml
        ln -sf ${pkgs.wiki-js}/server /var/lib/${cfg.stateDirectoryName}
        ln -sf ${pkgs.wiki-js}/assets /var/lib/${cfg.stateDirectoryName}
        ln -sf ${pkgs.wiki-js}/package.json /var/lib/${cfg.stateDirectoryName}/package.json
      '';

      serviceConfig = {
        DynamicUser = true;
        EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = "${pkgs.lib.getExe pkgs.nodejs-slim} ${pkgs.wiki-js}/server";
        PrivateTmp = true;
        StateDirectory = cfg.stateDirectoryName;
        WorkingDirectory = "/var/lib/${cfg.stateDirectoryName}";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with maintainers; [ ma27 ];
}
