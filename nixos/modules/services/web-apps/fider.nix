{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.fider;
  fiderCmd = lib.getExe cfg.package;
in
{
  options = {

    services.fider = {
      enable = lib.mkEnableOption "the Fider server";
      package = lib.mkPackageOption pkgs "fider" { };

      dataDir = lib.mkOption {
        default = "/var/lib/fider";
        description = "Default data folder for Fider.";
        example = "/mnt/fider";
        type = lib.types.str;
      };

      database = {
        url = lib.mkOption {
          default = "local";

          description = ''
            URI to use for the main PostgreSQL database. If this needs to include
            credentials that shouldn't be world-readable in the Nix store, set an
            environment file on the systemd service and override the
            `DATABASE_URL` entry. Pass the string
            `local` to setup a database on the local server.
          '';

          type = lib.types.str;
        };
      };

      environment = lib.mkOption {
        default = { };

        description = ''
          Environment variables to set for the service. Secrets should be
          specified using {option}`environmentFiles`.
          Refer to <https://github.com/getfider/fider/blob/stable/.example.env>
          and <https://github.com/getfider/fider/blob/stable/app/pkg/env/env.go>
          for available options.
        '';

        example = {
          BASE_URL = "https://fider.example.com";
          BLOB_STORAGE = "fs";
          EMAIL = "smtp";
          EMAIL_NOREPLY = "fider@example.com";
          EMAIL_SMTP_HOST = "mail.example.com";
          EMAIL_SMTP_PORT = "587";
          EMAIL_SMTP_USERNAME = "fider@example.com";
          PORT = "31213";
        };

        type = lib.types.attrsOf lib.types.str;
      };

      environmentFiles = lib.mkOption {
        default = [ ];

        description = ''
          Files to load environment variables from. Loaded variables override
          values set in {option}`environment`.
        '';

        example = "/run/secrets/fider.env";
        type = lib.types.listOf lib.types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = lib.mkIf (cfg.database.url == "local") {
      enable = true;
      ensureDatabases = [ "fider" ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = "fider";
        }
      ];
    };

    systemd.services.fider = {
      after = [
        "network.target"
      ]
      ++ lib.optionals (cfg.database.url == "local") [ "postgresql.target" ];

      description = "Fider server";

      environment =
        let
          localPostgresqlUrl = "postgres:///fider?host=/run/postgresql";
        in
        {
          BLOB_STORAGE_FS_PATH = "${cfg.dataDir}";
          DATABASE_URL = if (cfg.database.url == "local") then localPostgresqlUrl else cfg.database.url;
        }
        // cfg.environment;

      requires = lib.optionals (cfg.database.url == "local") [ "postgresql.target" ];

      serviceConfig = {
        CacheDirectory = "fider";
        DynamicUser = true;
        EnvironmentFile = cfg.environmentFiles;
        ExecStart = fiderCmd;
        ExecStartPre = "${fiderCmd} migrate";
        PrivateTmp = "yes";
        Restart = "on-failure";
        RuntimeDirectory = "fider";
        RuntimeDirectoryPreserve = true;
        StateDirectory = "fider";
        WorkingDirectory = "${cfg.package}";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    maintainers = with lib.maintainers; [
      niklaskorz
    ];
    # doc = ./fider.md;
  };
}
