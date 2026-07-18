{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ferretdb;
in
{

  options = {
    services.ferretdb = {
      enable = lib.mkEnableOption "FerretDB, an Open Source MongoDB alternative";
      package = lib.mkPackageOption pkgs "ferretdb" { };

      settings = lib.mkOption {
        description = ''
          Additional configuration for FerretDB, see
          <https://docs.ferretdb.io/configuration/flags/>
          for supported values.
        '';

        example = {
          FERRETDB_LOG_LEVEL = "warn";
          FERRETDB_MODE = "normal";
        };

        type = lib.types.submodule {
          options = {
            FERRETDB_HANDLER = lib.mkOption {
              default = "sqlite";
              description = "Backend handler";

              type = lib.types.enum [
                "sqlite"
                "pg"
              ];
            };

            FERRETDB_POSTGRESQL_URL = lib.mkOption {
              default = "postgres://ferretdb@localhost/ferretdb?host=/run/postgresql";
              description = "PostgreSQL URL for 'pg' handler";
              type = lib.types.str;
            };

            FERRETDB_SQLITE_URL = lib.mkOption {
              default = "file:/var/lib/ferretdb/";
              description = "SQLite URI (directory) for 'sqlite' handler";
              type = lib.types.str;
            };

            FERRETDB_TELEMETRY = lib.mkOption {
              default = "disable";

              description = ''
                Enable or disable basic telemetry.

                See <https://docs.ferretdb.io/telemetry/> for more information.
              '';

              type = lib.types.enum [
                "enable"
                "disable"
              ];
            };
          };

          freeformType = with lib.types; attrsOf str;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.ferretdb.settings = { };

    systemd.services.ferretdb = {
      after = [ "network.target" ];
      description = "FerretDB";
      environment = cfg.settings;

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/ferretdb";
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RemoveIPC = true;
        Restart = "on-failure";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "ferretdb";
        Type = "simple";
        WorkingDirectory = "/var/lib/ferretdb";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    julienmalka
    camillemndn
  ];
}
