{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.windmill;
in
{
  options.services.windmill = {
    enable = lib.mkEnableOption "windmill service";
    package = lib.mkPackageOption pkgs "windmill" { };

    baseUrl = lib.mkOption {
      default = "https://localhost:${toString config.services.windmill.serverPort}";

      defaultText = lib.literalExpression ''
        "https://localhost:\$\{toString config.services.windmill.serverPort}";
      '';

      description = ''
        The base url that windmill will be served on.
      '';

      example = "https://windmill.example.com";
      type = lib.types.str;
    };

    database = {
      createLocally = lib.mkOption {
        default = true;
        description = "Whether to create a local database automatically.";
        type = lib.types.bool;
      };

      name = lib.mkOption {
        # the simplest database setup is to have the database named like the user.
        default = "windmill";
        description = "Database name.";
        type = lib.types.str;
      };

      url = lib.mkOption {
        default = "postgres://${config.services.windmill.database.name}?host=/var/run/postgresql";

        defaultText = lib.literalExpression ''
          "postgres://\$\{config.services.windmill.database.name}?host=/var/run/postgresql";
        '';

        description = "Database url. Note that any secret here would be world-readable. Use `services.windmill.database.urlPath` unstead to include secrets in the url.";
        type = lib.types.str;
      };

      urlPath = lib.mkOption {
        default = null;

        description = ''
          Path to the file containing the database url windmill should connect to. This is not deducted from database user and name as it might contain a secret
        '';

        example = "config.age.secrets.DATABASE_URL_FILE.path";
        type = lib.types.nullOr lib.types.path;
      };

      user = lib.mkOption {
        # the simplest database setup is to have the database user like the name.
        default = "windmill";
        description = "Database user.";
        type = lib.types.str;
      };
    };

    logLevel = lib.mkOption {
      default = "info";
      description = "Log level";

      type = lib.types.enum [
        "error"
        "warn"
        "info"
        "debug"
        "trace"
      ];
    };

    lspPort = lib.mkOption {
      default = 3001;
      description = "Port the windmill lsp listens on.";
      type = lib.types.port;
    };

    serverPort = lib.mkOption {
      default = 8001;
      description = "Port the windmill server listens on.";
      type = lib.types.port;
    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.database.createLocally -> cfg.database.name == cfg.database.user;

        message = ''
          Automatically provisioning the windmill database requires both database name and database user to be equal. '${cfg.database.name}' != '${cfg.database.user}'
          To fix this problem, assign the same value to both options services.windmill.database.{name,user}.
        '';
      }
    ];

    services.postgresql = lib.optionalAttrs (cfg.database.createLocally) {
      enable = lib.mkDefault true;
      ensureDatabases = [ cfg.database.name ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = cfg.database.user;
        }
      ];
    };

    systemd.services =
      let
        useUrlPath = (cfg.database.urlPath != null);
        serviceConfig = {
          DynamicUser = true;
          ExecStart = lib.getExe cfg.package;
          Restart = "always";
          # using the same user to simplify db connection
          User = cfg.database.user;
        }
        // lib.optionalAttrs useUrlPath {
          LoadCredential = [
            "DATABASE_URL_FILE:${cfg.database.urlPath}"
          ];
        };
        db_url_envs =
          lib.optionalAttrs useUrlPath {
            DATABASE_URL_FILE = "%d/DATABASE_URL_FILE";
          }
          // lib.optionalAttrs (!useUrlPath) {
            DATABASE_URL = cfg.database.url;
          };
      in
      {
        windmill-initdb = lib.mkIf cfg.database.createLocally {
          after = [ "postgresql.target" ];

          before =
            [ ]
            ++ (lib.optionals config.systemd.services.windmill-server.enable [ "windmill-server.service" ])
            ++ (lib.optionals config.systemd.services.windmill-worker.enable [ "windmill-worker.service" ])
            ++ (lib.optionals config.systemd.services.windmill-worker-native.enable [
              "windmill-worker-native.service"
            ]);

          description = "Windmill database setup";
          path = [ config.services.postgresql.package ];

          requiredBy =
            [ ]
            ++ (lib.optionals config.systemd.services.windmill-server.enable [ "windmill-server.service" ])
            ++ (lib.optionals config.systemd.services.windmill-worker.enable [ "windmill-worker.service" ])
            ++ (lib.optionals config.systemd.services.windmill-worker-native.enable [
              "windmill-worker-native.service"
            ]);

          requires = [ "postgresql.target" ];

          # coming from https://github.com/windmill-labs/windmill/blob/main/init-db-as-superuser.sql
          # modified to not grant privileges on all tables
          # create role windmill_user and windmill_admin only if they don't exist
          script = ''
            psql -tA <<"EOF"
              DO $$
              BEGIN
                  IF NOT EXISTS (
                      SELECT FROM pg_catalog.pg_roles
                      WHERE rolname = 'windmill_user'
                  ) THEN
                      CREATE ROLE windmill_user;
                      GRANT ALL PRIVILEGES ON DATABASE ${cfg.database.name} TO windmill_user;
                  ELSE
                    RAISE NOTICE 'Role "windmill_user" already exists. Skipping.';
                  END IF;
                  IF NOT EXISTS (
                      SELECT FROM pg_catalog.pg_roles
                      WHERE rolname = 'windmill_admin'
                  ) THEN
                    CREATE ROLE windmill_admin WITH BYPASSRLS;
                    GRANT windmill_user TO windmill_admin;
                  ELSE
                    RAISE NOTICE 'Role "windmill_admin" already exists. Skipping.';
                  END IF;
                  GRANT windmill_admin TO ${cfg.database.user};
              END
              $$;
            EOF
          '';

          serviceConfig = {
            ProtectHome = "read-only";
            ProtectSystem = "strict";
            RemainAfterExit = true;
            Type = "oneshot";
            # Superuser because of required permission CREATE ROLE
            User = "postgres";
          };
        };

        windmill-server = {
          after = [ "network.target" ];
          description = "Windmill server";

          environment = {
            MODE = "server";
            PORT = toString cfg.serverPort;
            RUST_LOG = cfg.logLevel;
            WM_BASE_URL = cfg.baseUrl;
          }
          // db_url_envs;

          partOf = [ "windmill.target" ];

          serviceConfig = serviceConfig // {
            StateDirectory = "windmill";
          };
        };

        windmill-worker = {
          after = [ "network.target" ];
          description = "Windmill worker";

          environment = {
            KEEP_JOB_DIR = "false";
            MODE = "worker";
            RUST_LOG = cfg.logLevel;
            WM_BASE_URL = cfg.baseUrl;
            WORKER_GROUP = "default";
          }
          // db_url_envs;

          partOf = [ "windmill.target" ];

          serviceConfig = serviceConfig // {
            StateDirectory = "windmill-worker";
          };
        };

        windmill-worker-native = {
          after = [ "network.target" ];
          description = "Windmill worker native";

          environment = {
            MODE = "worker";
            RUST_LOG = cfg.logLevel;
            WM_BASE_URL = cfg.baseUrl;
            WORKER_GROUP = "native";
          }
          // db_url_envs;

          partOf = [ "windmill.target" ];

          serviceConfig = serviceConfig // {
            StateDirectory = "windmill-worker-native";
          };
        };
      };

    systemd.targets.windmill = {
      description = "Windmill";

      requires =
        [ ]
        ++ (lib.optionals config.systemd.services.windmill-server.enable [ "windmill-server.service" ])
        ++ (lib.optionals config.systemd.services.windmill-worker.enable [ "windmill-worker.service" ])
        ++ (lib.optionals config.systemd.services.windmill-worker-native.enable [
          "windmill-worker-native.service"
        ]);

      wantedBy = [ "multi-user.target" ];
    };
  };
}
