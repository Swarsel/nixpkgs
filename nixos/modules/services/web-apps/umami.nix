{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    filterAttrs
    getExe
    hasPrefix
    hasSuffix
    isString
    literalExpression
    maintainers
    mapAttrs
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optional
    optionalString
    types
    ;

  cfg = config.services.umami;

  nonFileSettings = filterAttrs (k: _: !hasSuffix "_FILE" k) cfg.settings;
in
{
  options.services.umami = {
    enable = mkEnableOption "umami";

    package = mkPackageOption pkgs "umami" { } // {
      apply =
        pkg:
        pkg.override {
          basePath = cfg.settings.BASE_PATH;

          collectApiEndpoint = optionalString (
            cfg.settings.COLLECT_API_ENDPOINT != null
          ) cfg.settings.COLLECT_API_ENDPOINT;

          trackerScriptNames = cfg.settings.TRACKER_SCRIPT_NAME;
        };
    };

    createPostgresqlDatabase = mkOption {
      default = true;

      description = ''
        Whether to automatically create the database for Umami using PostgreSQL.
        Both the database name and username will be `umami`, and the connection is
        made through unix sockets using peer authentication.
      '';

      example = false;
      type = types.bool;
    };

    settings = mkOption {
      default = { };

      description = ''
        Additional configuration (environment variables) for Umami, see
        <https://umami.is/docs/environment-variables> for supported values.
      '';

      example = {
        APP_SECRET_FILE = "/run/secrets/umamiAppSecret";
        DISABLE_TELEMETRY = true;
      };

      type = types.submodule {
        options = {
          APP_SECRET_FILE = mkOption {
            default = null;

            description = ''
              A file containing a secure random string. This is used for signing user sessions.
              The contents of the file are read through systemd credentials, therefore the
              user running umami does not need permissions to read the file.
              If you wish to set this to a string instead (not recommended since it will be
              placed world-readable in the Nix store), you can use the APP_SECRET option.
            '';

            example = "/run/secrets/umamiAppSecret";

            type = types.nullOr (
              types.str
              // {
                # We don't want users to be able to pass a path literal here but
                # it should look like a path.
                check = it: isString it && types.path.check it;
              }
            );
          };

          BASE_PATH = mkOption {
            default = "";

            description = ''
              Allows you to host Umami under a subdirectory.
              You may need to update your reverse proxy settings to correctly handle the BASE_PATH prefix.
            '';

            example = "/analytics";
            type = types.str;
          };

          COLLECT_API_ENDPOINT = mkOption {
            default = null;

            description = ''
              Allows you to send metrics to a location different than the default `/api/send`.
            '';

            example = "/api/alternate-send";
            type = types.nullOr types.str;
          };

          DATABASE_URL = mkOption {
            # For some reason, Prisma requires the username in the connection string
            # and can't derive it from the current user.
            default =
              if cfg.createPostgresqlDatabase then
                "postgresql://umami@localhost/umami?host=/run/postgresql"
              else
                null;

            defaultText = literalExpression ''if config.services.umami.createPostgresqlDatabase then "postgresql://umami@localhost/umami?host=/run/postgresql" else null'';

            description = ''
              Connection string for the database. Must start with `postgresql://` or `postgres://`.
            '';

            example = "postgresql://root:root@localhost/umami";

            type = types.nullOr (
              types.str
              // {
                check = it: isString it && ((hasPrefix "postgresql://" it) || (hasPrefix "postgres://" it));
              }
            );
          };

          DATABASE_URL_FILE = mkOption {
            default = null;

            description = ''
              A file containing a connection string for the database. The connection string
              must start with `postgresql://` or `postgres://`.
              The contents of the file are read through systemd credentials, therefore the
              user running umami does not need permissions to read the file.
            '';

            example = "/run/secrets/umamiDatabaseUrl";

            type = types.nullOr (
              types.str
              // {
                # We don't want users to be able to pass a path literal here but
                # it should look like a path.
                check = it: isString it && types.path.check it;
              }
            );
          };

          DISABLE_TELEMETRY = mkOption {
            default = false;

            description = ''
              Umami collects completely anonymous telemetry data in order help improve the application.
              You can choose to disable this if you don't want to participate.
            '';

            example = true;
            type = types.bool;
          };

          DISABLE_UPDATES = mkOption {
            default = true;

            description = ''
              Disables the check for new versions of Umami.
            '';

            example = false;
            type = types.bool;
          };

          HOSTNAME = mkOption {
            default = "127.0.0.1";

            description = ''
              The address to listen on.
            '';

            example = "0.0.0.0";
            type = types.str;
          };

          PORT = mkOption {
            default = 3000;

            description = ''
              The port to listen on.
            '';

            example = 3010;
            type = types.port;
          };

          TRACKER_SCRIPT_NAME = mkOption {
            default = [ ];

            description = ''
              Allows you to assign a custom name to the tracker script different from the default `script.js`.
            '';

            example = [ "tracker.js" ];
            type = types.listOf types.str;
          };
        };

        freeformType =
          with types;
          attrsOf (oneOf [
            bool
            int
            str
          ]);
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.settings.APP_SECRET_FILE != null) != (cfg.settings ? APP_SECRET);
        message = "One (and only one) of services.umami.settings.APP_SECRET_FILE and services.umami.settings.APP_SECRET must be set.";
      }
      {
        assertion = (cfg.settings.DATABASE_URL_FILE != null) != (cfg.settings.DATABASE_URL != null);
        message = "One (and only one) of services.umami.settings.DATABASE_URL_FILE and services.umami.settings.DATABASE_URL must be set.";
      }
      {
        assertion =
          cfg.createPostgresqlDatabase
          -> cfg.settings.DATABASE_URL == "postgresql://umami@localhost/umami?host=/run/postgresql";

        message = "The option config.services.umami.createPostgresqlDatabase is enabled, but config.services.umami.settings.DATABASE_URL has been modified.";
      }
      {
        assertion = cfg.settings.DATABASE_TYPE or null != "mysql";
        message = "Umami only supports PostgreSQL as of 3.0.0. Follow migration instructions if you are using MySQL: https://umami.is/docs/guides/migrate-mysql-postgresql";
      }
    ];

    services.postgresql = mkIf cfg.createPostgresqlDatabase {
      enable = true;
      ensureDatabases = [ "umami" ];

      ensureUsers = [
        {
          ensureClauses.login = true;
          ensureDBOwnership = true;
          name = "umami";
        }
      ];
    };

    systemd.services.umami = {
      after = [ "network.target" ] ++ (optional (cfg.createPostgresqlDatabase) "postgresql.service");
      description = "Umami: a simple, fast, privacy-focused alternative to Google Analytics";
      environment = mapAttrs (_: toString) nonFileSettings;

      script =
        let
          loadCredentials =
            (optional (
              cfg.settings.APP_SECRET_FILE != null
            ) ''export APP_SECRET="$(systemd-creds cat appSecret)"'')
            ++ (optional (
              cfg.settings.DATABASE_URL_FILE != null
            ) ''export DATABASE_URL="$(systemd-creds cat databaseUrl)"'');
        in
        ''
          ${concatStringsSep "\n" loadCredentials}
          ${getExe cfg.package}
        '';

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = "";
        DynamicUser = true;

        LoadCredential =
          (optional (cfg.settings.APP_SECRET_FILE != null) "appSecret:${cfg.settings.APP_SECRET_FILE}")
          ++ (optional (
            cfg.settings.DATABASE_URL_FILE != null
          ) "databaseUrl:${cfg.settings.DATABASE_URL_FILE}");

        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        Restart = "on-failure";
        RestartSec = 3;

        RestrictAddressFamilies = (optional cfg.createPostgresqlDatabase "AF_UNIX") ++ [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with maintainers; [ diogotcorreia ];
}
