{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.davis;
  db = cfg.database;
  mail = cfg.mail;

  mysqlLocal = db.createLocally && db.driver == "mysql";
  pgsqlLocal = db.createLocally && db.driver == "postgresql";

  user = cfg.user;
  group = cfg.group;

  isSecret = v: lib.isAttrs v && v ? _secret && (lib.isString v._secret || builtins.isPath v._secret);
  davisEnvVars = lib.generators.toKeyValue {
    mkKeyValue = lib.flip lib.generators.mkKeyValueDefault "=" {
      mkValueString =
        v:
        if builtins.isInt v then
          toString v
        else if lib.isString v then
          "\"${v}\""
        else if true == v then
          "true"
        else if false == v then
          "false"
        else if null == v then
          ""
        else if isSecret v then
          if (lib.isString v._secret) then
            builtins.hashString "sha256" v._secret
          else
            builtins.hashString "sha256" (builtins.readFile v._secret)
        else
          throw "unsupported type ${builtins.typeOf v}: ${(lib.generators.toPretty { }) v}";
    };
  };
  secretPaths = lib.mapAttrsToList (_: v: v._secret) (lib.filterAttrs (_: isSecret) cfg.config);
  mkSecretReplacement = file: ''
    replace-secret ${
      lib.escapeShellArgs [
        (
          if (lib.isString file) then
            builtins.hashString "sha256" file
          else
            builtins.hashString "sha256" (builtins.readFile file)
        )
        file
        "${cfg.dataDir}/.env.local"
      ]
    }
  '';
  secretReplacements = lib.concatMapStrings mkSecretReplacement secretPaths;
  filteredConfig = lib.converge (lib.filterAttrsRecursive (
    _: v:
    !lib.elem v [
      { }
      null
    ]
  )) cfg.config;
  davisEnv = pkgs.writeText "davis.env" (davisEnvVars filteredConfig);
in
{
  options.services.davis = {
    config = lib.mkOption {
      default = { };
      description = "";
      example = "";

      type = lib.types.attrsOf (
        lib.types.nullOr (
          lib.types.either
            (lib.types.oneOf [
              lib.types.bool
              lib.types.int
              lib.types.port
              lib.types.path
              lib.types.str
            ])
            (
              lib.types.submodule {
                options = {
                  _secret = lib.mkOption {
                    description = ''
                      The path to a file containing the value the
                      option should be set to in the final
                      configuration file.
                    '';

                    type = lib.types.nullOr (
                      lib.types.oneOf [
                        lib.types.str
                        lib.types.path
                      ]
                    );
                  };
                };
              }
            )
        )
      );
    };

    enable = lib.mkEnableOption "Davis is a caldav and carddav server";
    package = lib.mkPackageOption pkgs "davis" { };

    adminLogin = lib.mkOption {
      default = "root";

      description = ''
        Username for the admin account.
      '';

      type = lib.types.str;
    };

    adminPasswordFile = lib.mkOption {
      description = ''
        The full path to a file that contains the admin's password. Must be
        readable by the user.
      '';

      example = "/run/secrets/davis-admin-pass";
      type = lib.types.path;
    };

    appSecretFile = lib.mkOption {
      description = ''
        A file containing the Symfony APP_SECRET - Its value should be a series
        of characters, numbers and symbols chosen randomly and the recommended
        length is around 32 characters. Can be generated with <code>cat
        /dev/urandom | tr -dc a-zA-Z0-9 | fold -w 48 | head -n 1</code>.
      '';

      example = "/run/secrets/davis-appsecret";
      type = lib.types.path;
    };

    dataDir = lib.mkOption {
      default = "/var/lib/davis";

      description = ''
        Davis data directory.
      '';

      type = lib.types.path;
    };

    database = {
      createLocally = lib.mkOption {
        default = true;
        description = "Create the database and database user locally.";
        type = lib.types.bool;
      };

      driver = lib.mkOption {
        default = "sqlite";
        description = "Database type, required in all circumstances.";

        type = lib.types.enum [
          "sqlite"
          "postgresql"
          "mysql"
        ];
      };

      name = lib.mkOption {
        default = "davis";
        description = "Database name, only used when the database is created locally.";
        type = lib.types.nullOr lib.types.str;
      };

      urlFile = lib.mkOption {
        default = null;

        description = ''
          A file containing the database connection url. If set then it
          overrides all other database settings (except driver). This is
          mandatory if you want to use an external database, that is when
          `services.davis.database.createLocally` is `false`.
        '';

        example = "/run/secrets/davis-db-url";
        type = lib.types.nullOr lib.types.path;
      };
    };

    group = lib.mkOption {
      default = "davis";
      description = "Group davis runs as.";
      type = lib.types.str;
    };

    hostname = lib.mkOption {
      description = ''
        Domain of the host to serve davis under. You may want to change it if you
        run Davis on a different URL than davis.yourdomain.
      '';

      example = "davis.yourdomain.org";
      type = lib.types.str;
    };

    mail = {
      dsn = lib.mkOption {
        default = null;
        description = "Mail DSN for sending emails. Mutually exclusive with `services.davis.mail.dsnFile`.";
        example = "smtp://username:password@example.com:25";
        type = lib.types.nullOr lib.types.str;
      };

      dsnFile = lib.mkOption {
        default = null;
        description = "A file containing the mail DSN for sending emails.  Mutually exclusive with `servies.davis.mail.dsn`.";
        example = "/run/secrets/davis-mail-dsn";
        type = lib.types.nullOr lib.types.str;
      };

      inviteFromAddress = lib.mkOption {
        default = null;
        description = "Email address to send invitations from.";
        example = "no-reply@dav.example.com";
        type = lib.types.nullOr lib.types.str;
      };
    };

    nginx = lib.mkOption {
      default = { };

      description = ''
        Use this option to customize an nginx virtual host. To disable the nginx set this to null.
      '';

      example = ''
        {
          serverAliases = [
            "dav.''${config.networking.domain}"
          ];
          # To enable encryption and let let's encrypt take care of certificate
          forceSSL = true;
          enableACME = true;
        }
      '';

      type = lib.types.nullOr (
        lib.types.submodule (
          lib.recursiveUpdate (import ../web-servers/nginx/vhost-options.nix { inherit config lib; }) {
          }
        )
      );
    };

    poolConfig = lib.mkOption {
      default = {
        "pm" = "dynamic";
        "pm.max_children" = 32;
        "pm.max_requests" = 500;
        "pm.max_spare_servers" = 4;
        "pm.min_spare_servers" = 2;
        "pm.start_servers" = 2;
      };

      description = ''
        Options for the davis PHP pool. See the documentation on <literal>php-fpm.conf</literal>
        for details on configuration directives.
      '';

      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.str
          lib.types.int
          lib.types.bool
        ]
      );
    };

    user = lib.mkOption {
      default = "davis";
      description = "User davis runs as.";
      type = lib.types.str;
    };
  };

  config =
    let
      defaultServiceConfig = {
        DeviceAllow = "";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        ReadWritePaths = "${cfg.dataDir}";
        RemoveIPC = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@resources"
          "~@privileged"
        ];

        UMask = 77;
        User = user;
        WorkingDirectory = "${cfg.package}/";
      };
    in
    lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = db.createLocally -> db.urlFile == null;
          message = "services.davis.database.urlFile must be unset if services.davis.database.createLocally is set true.";
        }
        {
          assertion = db.createLocally || db.urlFile != null;
          message = "One of services.davis.database.urlFile or services.davis.database.createLocally must be set.";
        }
        {
          assertion = !(mail.dsn != null && mail.dsnFile != null);
          message = "services.davis.mail.dsn and services.davis.mail.dsnFile cannot both be set.";
        }
      ];

      services.davis.config = {
        ADMIN_LOGIN = cfg.adminLogin;
        ADMIN_PASSWORD._secret = cfg.adminPasswordFile;
        APP_CACHE_DIR = "${cfg.dataDir}/var/cache";
        APP_ENV = "prod";
        APP_LOG_DIR = "${cfg.dataDir}/var/log";
        APP_SECRET._secret = cfg.appSecretFile;
        APP_TIMEZONE = config.time.timeZone;
        CALDAV_ENABLED = true;
        CARDDAV_ENABLED = true;
        DATABASE_DRIVER = db.driver;
        INVITE_FROM_ADDRESS = mail.inviteFromAddress;
        LOG_FILE_PATH = "%kernel.logs_dir%/%kernel.environment%.log";
        WEBDAV_ENABLED = false;
      }
      // (
        if mail.dsn != null then
          { MAILER_DSN = mail.dsn; }
        else if mail.dsnFile != null then
          { MAILER_DSN._secret = mail.dsnFile; }
        else
          { }
      )
      // (
        if db.createLocally then
          {
            DATABASE_URL =
              if db.driver == "sqlite" then
                "sqlite:///${cfg.dataDir}/davis.db" # note: sqlite needs 4 slashes for an absolute path
              else if
                pgsqlLocal
              # note: davis expects a non-standard postgres uri (due to the underlying doctrine library)
              # specifically the dummy hostname which is overridden by the host query parameter
              then
                "postgres://${user}@localhost/${db.name}?host=/run/postgresql"
              else if mysqlLocal then
                "mysql://${user}@localhost/${db.name}?socket=/run/mysqld/mysqld.sock"
              else
                null;
          }
        else
          { DATABASE_URL._secret = db.urlFile; }
      );

      services.mysql = lib.mkIf mysqlLocal {
        enable = true;
        package = lib.mkDefault pkgs.mariadb;
        ensureDatabases = [ db.name ];

        ensureUsers = [
          {
            ensurePermissions = {
              "${db.name}.*" = "ALL PRIVILEGES";
            };

            name = user;
          }
        ];
      };

      services.nginx = lib.mkIf (cfg.nginx != null) {
        enable = lib.mkDefault true;

        virtualHosts = {
          "${cfg.hostname}" = lib.mkMerge [
            cfg.nginx
            {
              extraConfig = ''
                charset utf-8;
                index index.php;
              '';

              locations = {
                "/" = {
                  extraConfig = ''
                    try_files $uri $uri/ /index.php$is_args$args;
                  '';
                };

                "~ /(\\.ht)" = {
                  extraConfig = ''
                    deny all;
                    return 404;
                  '';
                };

                "~ ^(.+\\.php)(.*)$" = {
                  extraConfig = ''
                    try_files                $fastcgi_script_name =404;
                    include                  ${config.services.nginx.package}/conf/fastcgi_params;
                    include                  ${config.services.nginx.package}/conf/fastcgi.conf;
                    fastcgi_pass             unix:${config.services.phpfpm.pools.davis.socket};
                    fastcgi_param            SCRIPT_FILENAME  $document_root$fastcgi_script_name;
                    fastcgi_param            PATH_INFO        $fastcgi_path_info;
                    fastcgi_split_path_info  ^(.+\.php)(.*)$;
                    fastcgi_param            X-Forwarded-Proto https;
                    fastcgi_param            X-Forwarded-Port $http_x_forwarded_port;
                  '';
                };

                "~* ^/.well-known/(caldav|carddav)$" = {
                  extraConfig = ''
                    return 302 https://$host/dav/;
                  '';
                };
              };

              root = lib.mkForce "${cfg.package}/public";
            }
          ];
        };
      };

      services.phpfpm.pools.davis = {
        inherit user group;

        phpEnv = {
          APP_CACHE_DIR = "${cfg.dataDir}/var/cache";
          APP_LOG_DIR = "${cfg.dataDir}/var/log";
          ENV_DIR = "${cfg.dataDir}";
        };

        phpOptions = ''
          log_errors = on
        '';

        phpPackage = lib.mkDefault cfg.package.passthru.php;

        settings = {
          "listen.mode" = "0660";
          "pm" = "dynamic";
          "pm.max_children" = 256;
          "pm.max_spare_servers" = 20;
          "pm.min_spare_servers" = 5;
          "pm.start_servers" = 10;
        }
        // (
          if cfg.nginx != null then
            {
              "listen.group" = config.services.nginx.group;
              "listen.owner" = config.services.nginx.user;
            }
          else
            { }
        )
        // cfg.poolConfig;
      };

      services.postgresql = lib.mkIf pgsqlLocal {
        enable = true;
        ensureDatabases = [ db.name ];

        ensureUsers = [
          {
            ensureDBOwnership = true;
            name = user;
          }
        ];
      };

      systemd.services.davis-db-migrate = {
        after =
          lib.optional mysqlLocal "mysql.service"
          ++ lib.optional pgsqlLocal "postgresql.target"
          ++ [ "davis-env-setup.service" ];

        before = [ "phpfpm-davis.service" ];
        description = "Migrate davis database";

        requires =
          lib.optional mysqlLocal "mysql.service"
          ++ lib.optional pgsqlLocal "postgresql.target"
          ++ [ "davis-env-setup.service" ];

        restartTriggers = [
          cfg.package
          davisEnv
        ];

        script = ''
          set -euo pipefail
          ${cfg.package}/bin/console cache:clear --no-debug
          ${cfg.package}/bin/console cache:warmup --no-debug
          ${cfg.package}/bin/console doctrine:migrations:migrate
        '';

        serviceConfig = defaultServiceConfig // {
          Environment = [
            "ENV_DIR=${cfg.dataDir}"
            "APP_CACHE_DIR=${cfg.dataDir}/var/cache"
            "APP_LOG_DIR=${cfg.dataDir}/var/log"
          ];

          EnvironmentFile = "${cfg.dataDir}/.env.local";
          RemainAfterExit = true;
          Type = "oneshot";
        };

        wantedBy = [ "multi-user.target" ];
      };

      # Reading the user-provided secret files requires root access
      systemd.services.davis-env-setup = {
        before = [
          "phpfpm-davis.service"
          "davis-db-migrate.service"
        ];

        description = "Setup davis environment";
        path = [ pkgs.replace-secret ];

        restartTriggers = [
          cfg.package
          davisEnv
        ];

        script = ''
          # error handling
          set -euo pipefail
          # create .env file with the upstream values
          install -T -m 0600 -o ${user} ${cfg.package}/env-upstream "${cfg.dataDir}/.env"
          # create .env.local file with the user-provided values
          install -T -m 0600 -o ${user} ${davisEnv} "${cfg.dataDir}/.env.local"
          ${secretReplacements}
        '';

        serviceConfig = {
          RemainAfterExit = true;
          Type = "oneshot";
        };

        wantedBy = [ "multi-user.target" ];
      };

      systemd.services.phpfpm-davis.after = [
        "davis-env-setup.service"
        "davis-db-migrate.service"
      ];

      systemd.services.phpfpm-davis.requires = [
        "davis-env-setup.service"
        "davis-db-migrate.service"
      ]
      ++ lib.optional mysqlLocal "mysql.service"
      ++ lib.optional pgsqlLocal "postgresql.target";

      systemd.services.phpfpm-davis.serviceConfig.ReadWritePaths = [ cfg.dataDir ];

      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir}                            0710 ${user} ${group} - -"
        "d ${cfg.dataDir}/var                        0700 ${user} ${group} - -"
        "d ${cfg.dataDir}/var/log                    0700 ${user} ${group} - -"
        "d ${cfg.dataDir}/var/cache                  0700 ${user} ${group} - -"
      ];

      users = {
        groups = lib.mkIf (group == "davis") { davis = { }; };

        users = lib.mkIf (user == "davis") {
          davis = {
            description = "Davis service user";
            group = cfg.group;
            home = cfg.dataDir;
            isSystemUser = true;
          };
        };
      };
    };

  meta = {
    doc = ./davis.md;
    maintainers = pkgs.davis.meta.maintainers;
  };
}
