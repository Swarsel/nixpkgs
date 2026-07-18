{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.gammu-smsd;

  configFile = pkgs.writeText "gammu-smsd.conf" ''
    [gammu]
    Device = ${cfg.device.path}
    Connection = ${cfg.device.connection}
    SynchronizeTime = ${lib.boolToYesNo cfg.device.synchronizeTime}
    LogFormat = ${cfg.log.format}
    ${lib.optionalString (cfg.device.pin != null) "PIN = ${cfg.device.pin}"}
    ${cfg.extraConfig.gammu}


    [smsd]
    LogFile = ${cfg.log.file}
    Service = ${cfg.backend.service}

    ${lib.optionalString (cfg.backend.service == "files") ''
      InboxPath = ${cfg.backend.files.inboxPath}
      OutboxPath = ${cfg.backend.files.outboxPath}
      SentSMSPath = ${cfg.backend.files.sentSMSPath}
      ErrorSMSPath = ${cfg.backend.files.errorSMSPath}
    ''}

    ${lib.optionalString (cfg.backend.service == "sql" && cfg.backend.sql.driver == "sqlite") ''
      Driver = ${cfg.backend.sql.driver}
      DBDir = ${cfg.backend.sql.database}
    ''}

    ${lib.optionalString (cfg.backend.service == "sql" && cfg.backend.sql.driver == "native_pgsql") (
      with cfg.backend;
      ''
        Driver = ${sql.driver}
        ${lib.optionalString (sql.database != null) "Database = ${sql.database}"}
        ${lib.optionalString (sql.host != null) "Host = ${sql.host}"}
        ${lib.optionalString (sql.user != null) "User = ${sql.user}"}
        ${lib.optionalString (sql.password != null) "Password = ${sql.password}"}
      ''
    )}

    ${cfg.extraConfig.smsd}
  '';

  initDBDir = "share/doc/gammu/examples/sql";

  gammuPackage =
    with cfg.backend;
    (pkgs.gammu.override {
      dbiSupport = service == "sql" && sql.driver == "sqlite";
      postgresSupport = service == "sql" && sql.driver == "native_pgsql";
    });

in
{
  options = {
    services.gammu-smsd = {

      enable = lib.mkEnableOption "gammu-smsd daemon";

      backend = {
        files = {
          errorSMSPath = lib.mkOption {
            default = "/var/spool/sms/error/";
            description = "Where SMSes with error in transmission is placed";
            type = lib.types.path;
          };

          inboxPath = lib.mkOption {
            default = "/var/spool/sms/inbox/";
            description = "Where the received SMSes are stored";
            type = lib.types.path;
          };

          outboxPath = lib.mkOption {
            default = "/var/spool/sms/outbox/";
            description = "Where SMSes to be sent should be placed";
            type = lib.types.path;
          };

          sentSMSPath = lib.mkOption {
            default = "/var/spool/sms/sent/";
            description = "Where the transmitted SMSes are placed";
            type = lib.types.path;
          };
        };

        service = lib.mkOption {
          default = "null";
          description = "Service to use to store sms data.";

          type = lib.types.enum [
            "null"
            "files"
            "sql"
          ];
        };

        sql = {
          database = lib.mkOption {
            default = null;
            description = "Database name to store sms data";
            type = lib.types.nullOr lib.types.str;
          };

          driver = lib.mkOption {
            description = "DB driver to use";

            type = lib.types.enum [
              "native_mysql"
              "native_pgsql"
              "odbc"
              "dbi"
            ];
          };

          host = lib.mkOption {
            default = "localhost";
            description = "Database server address";
            type = lib.types.str;
          };

          password = lib.mkOption {
            default = null;
            description = "User password used for connection to the database";
            type = lib.types.nullOr lib.types.str;
          };

          sqlDialect = lib.mkOption {
            default = null;
            description = "SQL dialect to use (odbc driver only)";
            type = lib.types.nullOr lib.types.str;
          };

          user = lib.mkOption {
            default = null;
            description = "User name used for connection to the database";
            type = lib.types.nullOr lib.types.str;
          };
        };
      };

      device = {
        connection = lib.mkOption {
          default = "at";
          description = "Protocol which will be used to talk to the phone";
          type = lib.types.str;
        };

        group = lib.mkOption {
          default = "root";
          description = "Owner group of the device";
          example = "dialout";
          type = lib.types.str;
        };

        path = lib.mkOption {
          description = "Device node or address of the phone";
          example = "/dev/ttyUSB2";
          type = lib.types.path;
        };

        pin = lib.mkOption {
          default = null;
          description = "PIN code for the simcard";
          type = lib.types.nullOr lib.types.str;
        };

        synchronizeTime = lib.mkOption {
          default = true;
          description = "Whether to set time from computer to the phone during starting connection";
          type = lib.types.bool;
        };
      };

      extraConfig = {
        gammu = lib.mkOption {
          default = "";
          description = "Extra config lines to be added into [gammu] section";
          type = lib.types.lines;
        };

        smsd = lib.mkOption {
          default = "";
          description = "Extra config lines to be added into [smsd] section";
          type = lib.types.lines;
        };
      };

      log = {
        file = lib.mkOption {
          default = "syslog";
          description = "Path to file where information about communication will be stored";
          type = lib.types.str;
        };

        format = lib.mkOption {
          default = "errors";
          description = "Determines what will be logged to the LogFile";

          type = lib.types.enum [
            "nothing"
            "text"
            "textall"
            "textalldate"
            "errors"
            "errorsdate"
            "binary"
          ];
        };
      };

      user = lib.mkOption {
        default = "smsd";
        description = "User that has access to the device";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      with cfg.backend;
      [ gammuPackage ] ++ lib.optionals (service == "sql" && sql.driver == "sqlite") [ pkgs.sqlite ];

    systemd.services.gammu-smsd = {
      description = "gammu-smsd daemon";

      preStart =
        with cfg.backend;

        lib.optionalString (service == "files") (
          with files;
          ''
            mkdir -m 755 -p ${inboxPath} ${outboxPath} ${sentSMSPath} ${errorSMSPath}
            chown ${cfg.user} -R ${inboxPath}
            chown ${cfg.user} -R ${outboxPath}
            chown ${cfg.user} -R ${sentSMSPath}
            chown ${cfg.user} -R ${errorSMSPath}
          ''
        )
        + lib.optionalString (service == "sql" && sql.driver == "sqlite") ''
          cat "${gammuPackage}/${initDBDir}/sqlite.sql" \
          | ${pkgs.sqlite.bin}/bin/sqlite3 ${sql.database}
        ''
        + (
          let
            execPsql =
              extraArgs:
              lib.concatStringsSep " " [
                (lib.optionalString (sql.password != null) "PGPASSWORD=${sql.password}")
                "${config.services.postgresql.package}/bin/psql"
                (lib.optionalString (sql.host != null) "-h ${sql.host}")
                (lib.optionalString (sql.user != null) "-U ${sql.user}")
                "$extraArgs"
                "${sql.database}"
              ];
          in
          lib.optionalString (service == "sql" && sql.driver == "native_pgsql") ''
            echo '\i '"${gammuPackage}/${initDBDir}/pgsql.sql" | ${execPsql ""}
          ''
        );

      serviceConfig = {
        ExecStart = "${gammuPackage}/bin/gammu-smsd -c ${configFile}";
        Group = "${cfg.device.group}";
        PermissionsStartOnly = true;
        User = "${cfg.user}";
      };

      wantedBy = [ "multi-user.target" ];

      wants =
        with cfg.backend;
        [ ] ++ lib.optionals (service == "sql" && sql.driver == "native_pgsql") [ "postgresql.target" ];

    };

    users.users.${cfg.user} = {
      description = "gammu-smsd user";
      group = cfg.device.group;
      isSystemUser = true;
    };
  };
}
