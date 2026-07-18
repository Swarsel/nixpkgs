{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.forgejo;
  opt = options.services.forgejo;
  format = pkgs.formats.ini { };

  exe = lib.getExe cfg.package;

  pg = config.services.postgresql;
  useMysql = cfg.database.type == "mysql";
  usePostgresql = cfg.database.type == "postgres";
  useSqlite = cfg.database.type == "sqlite3";

  secrets =
    let
      mkSecret =
        section: values:
        lib.mapAttrsToList (key: value: {
          env = envEscape "FORGEJO__${section}__${key}__FILE";
          path = value;
        }) values;
      # https://codeberg.org/forgejo/forgejo/src/tag/v7.0.2/contrib/environment-to-ini/environment-to-ini.go
      envEscape =
        string: lib.replaceStrings [ "." "-" ] [ "_0X2E_" "_0X2D_" ] (lib.strings.toUpper string);
    in
    lib.flatten (lib.mapAttrsToList mkSecret cfg.secrets);

  inherit (lib)
    literalExpression
    mkChangedOptionModule
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkPackageOption
    mkRemovedOptionModule
    mkRenamedOptionModule
    optionalAttrs
    optionals
    optionalString
    types
    ;
in
{
  imports = [
    (mkRenamedOptionModule
      [ "services" "forgejo" "appName" ]
      [ "services" "forgejo" "settings" "DEFAULT" "APP_NAME" ]
    )
    (mkRemovedOptionModule [ "services" "forgejo" "extraConfig" ]
      "services.forgejo.extraConfig has been removed. Please use the freeform services.forgejo.settings option instead"
    )
    (mkRemovedOptionModule [ "services" "forgejo" "database" "password" ]
      "services.forgejo.database.password has been removed. Please use services.forgejo.database.passwordFile instead"
    )
    (mkRenamedOptionModule
      [ "services" "forgejo" "mailerPasswordFile" ]
      [ "services" "forgejo" "secrets" "mailer" "PASSWD" ]
    )

    # copied from services.gitea; remove at some point
    (mkRenamedOptionModule
      [ "services" "forgejo" "cookieSecure" ]
      [ "services" "forgejo" "settings" "session" "COOKIE_SECURE" ]
    )
    (mkRenamedOptionModule
      [ "services" "forgejo" "disableRegistration" ]
      [ "services" "forgejo" "settings" "service" "DISABLE_REGISTRATION" ]
    )
    (mkRenamedOptionModule
      [ "services" "forgejo" "domain" ]
      [ "services" "forgejo" "settings" "server" "DOMAIN" ]
    )
    (mkRenamedOptionModule
      [ "services" "forgejo" "httpAddress" ]
      [ "services" "forgejo" "settings" "server" "HTTP_ADDR" ]
    )
    (mkRenamedOptionModule
      [ "services" "forgejo" "httpPort" ]
      [ "services" "forgejo" "settings" "server" "HTTP_PORT" ]
    )
    (mkRenamedOptionModule
      [ "services" "forgejo" "log" "level" ]
      [ "services" "forgejo" "settings" "log" "LEVEL" ]
    )
    (mkRenamedOptionModule
      [ "services" "forgejo" "log" "rootPath" ]
      [ "services" "forgejo" "settings" "log" "ROOT_PATH" ]
    )
    (mkRenamedOptionModule
      [ "services" "forgejo" "rootUrl" ]
      [ "services" "forgejo" "settings" "server" "ROOT_URL" ]
    )
    (mkRenamedOptionModule
      [ "services" "forgejo" "ssh" "clonePort" ]
      [ "services" "forgejo" "settings" "server" "SSH_PORT" ]
    )
    (mkRenamedOptionModule
      [ "services" "forgejo" "staticRootPath" ]
      [ "services" "forgejo" "settings" "server" "STATIC_ROOT_PATH" ]
    )
    (mkChangedOptionModule
      [ "services" "forgejo" "enableUnixSocket" ]
      [ "services" "forgejo" "settings" "server" "PROTOCOL" ]
      (config: if config.services.forgejo.enableUnixSocket then "http+unix" else "http")
    )
    (mkRemovedOptionModule [ "services" "forgejo" "ssh" "enable" ]
      "services.forgejo.ssh.enable has been migrated into freeform setting services.forgejo.settings.server.DISABLE_SSH. Keep in mind that the setting is inverted"
    )
  ];

  options = {
    services.forgejo = {
      enable = mkEnableOption "Forgejo, a software forge";
      package = mkPackageOption pkgs "forgejo-lts" { };

      customDir = mkOption {
        default = "${cfg.stateDir}/custom";
        defaultText = literalExpression ''"''${config.${opt.stateDir}}/custom"'';

        description = ''
          Base directory for custom templates and other options.

          If {option}`${opt.useWizard}` is disabled (default), this directory will also
          hold secrets and the resulting {file}`app.ini` config at runtime.
        '';

        type = types.str;
      };

      database = {
        createDatabase = mkOption {
          default = true;
          description = "Whether to create a local database automatically.";
          type = types.bool;
        };

        host = mkOption {
          default = "127.0.0.1";
          description = "Database host address.";
          type = types.str;
        };

        name = mkOption {
          default = "forgejo";
          description = "Database name.";
          type = types.str;
        };

        passwordFile = mkOption {
          default = null;

          description = ''
            A file containing the password corresponding to
            {option}`${opt.database.user}`.
          '';

          example = "/run/keys/forgejo-dbpassword";
          type = types.nullOr types.path;
        };

        path = mkOption {
          default = "${cfg.stateDir}/data/forgejo.db";
          defaultText = literalExpression ''"''${config.${opt.stateDir}}/data/forgejo.db"'';
          description = "Path to the sqlite3 database file.";
          type = types.str;
        };

        port = mkOption {
          default = if usePostgresql then pg.settings.port else 3306;

          defaultText = literalExpression ''
            if config.${opt.database.type} != "postgresql"
            then 3306
            else 5432
          '';

          description = "Database host port.";
          type = types.port;
        };

        socket = mkOption {
          default =
            if (cfg.database.createDatabase && usePostgresql) then
              "/run/postgresql"
            else if (cfg.database.createDatabase && useMysql) then
              "/run/mysqld/mysqld.sock"
            else
              null;

          defaultText = literalExpression "null";
          description = "Path to the unix socket file to use for authentication.";
          example = "/run/mysqld/mysqld.sock";
          type = types.nullOr types.path;
        };

        type = mkOption {
          default = "sqlite3";
          description = "Database engine to use.";
          example = "mysql";

          type = types.enum [
            "sqlite3"
            "mysql"
            "postgres"
          ];
        };

        user = mkOption {
          default = "forgejo";
          description = "Database user.";
          type = types.str;
        };
      };

      dump = {
        enable = mkEnableOption "periodic dumps via the [built-in {command}`dump` command](https://forgejo.org/docs/latest/admin/command-line/#dump)";

        age = mkOption {
          default = "4w";

          description = ''
            Age of backup used to decide what files to delete when cleaning.
            If a file or directory is older than the current time minus the age field, it is deleted.

            The format is described in
            {manpage}`tmpfiles.d(5)`.
          '';

          example = "5d";
          type = types.str;
        };

        backupDir = mkOption {
          default = "${cfg.stateDir}/dump";
          defaultText = literalExpression ''"''${config.${opt.stateDir}}/dump"'';
          description = "Path to the directory where the dump archives will be stored.";
          type = types.str;
        };

        file = mkOption {
          default = null;
          description = "Filename to be used for the dump. If `null` a default name is chosen by forgejo.";
          example = "forgejo-dump";
          type = types.nullOr types.str;
        };

        interval = mkOption {
          default = "04:31";

          description = ''
            Run a Forgejo dump at this interval. Runs by default at 04:31 every day.

            The format is described in
            {manpage}`systemd.time(7)`.
          '';

          example = "hourly";
          type = types.str;
        };

        type = mkOption {
          default = "zip";
          description = "Archive format used to store the dump file.";

          type = types.enum [
            "zip"
            "tar"
            "tar.sz"
            "tar.gz"
            "tar.xz"
            "tar.bz2"
            "tar.br"
            "tar.lz4"
            "tar.zst"
          ];
        };
      };

      group = mkOption {
        default = "forgejo";
        description = "Group under which Forgejo runs.";
        type = types.str;
      };

      lfs = {
        enable = mkOption {
          default = false;
          description = "Enables git-lfs support.";
          type = types.bool;
        };

        contentDir = mkOption {
          default = "${cfg.stateDir}/data/lfs";
          defaultText = literalExpression ''"''${config.${opt.stateDir}}/data/lfs"'';
          description = "Where to store LFS files.";
          type = types.str;
        };
      };

      repositoryRoot = mkOption {
        default = "${cfg.stateDir}/repositories";
        defaultText = literalExpression ''"''${config.${opt.stateDir}}/repositories"'';
        description = "Path to the git repositories.";
        type = types.str;
      };

      secrets = mkOption {
        default = { };

        description = ''
          This is a small wrapper over systemd's `LoadCredential`.

          It takes the same sections and keys as {option}`services.forgejo.settings`,
          but the value of each key is a path instead of a string or bool.

          The path is then loaded as credential, exported as environment variable
          and then feed through
          <https://codeberg.org/forgejo/forgejo/src/branch/forgejo/contrib/environment-to-ini/environment-to-ini.go>.

          It does the required environment variable escaping for you.

          ::: {.note}
          Keys specified here take priority over the ones in {option}`services.forgejo.settings`!
          :::
        '';

        example = literalExpression ''
          {
            metrics = {
              TOKEN = "/run/keys/forgejo-metrics-token";
            };
            camo = {
              HMAC_KEY = "/run/keys/forgejo-camo-hmac";
            };
            service = {
              HCAPTCHA_SECRET = "/run/keys/forgejo-hcaptcha-secret";
              HCAPTCHA_SITEKEY = "/run/keys/forgejo-hcaptcha-sitekey";
            };
          }
        '';

        type = types.submodule {
          options = { };
          freeformType = with types; attrsOf (attrsOf path);
        };
      };

      settings = mkOption {
        default = { };

        description = ''
          Free-form settings written directly to the `app.ini` configfile file.
          Refer to <https://forgejo.org/docs/latest/admin/config-cheat-sheet/> for supported values.
        '';

        example = literalExpression ''
          {
            DEFAULT = {
              RUN_MODE = "dev";
            };
            "cron.sync_external_users" = {
              RUN_AT_START = true;
              SCHEDULE = "@every 24h";
              UPDATE_EXISTING = true;
            };
            mailer = {
              ENABLED = true;
              PROTOCOL = "sendmail";
              FROM = "do-not-reply@example.org";
              SENDMAIL_PATH = "''${pkgs.system-sendmail}/bin/sendmail";
            };
            other = {
              SHOW_FOOTER_VERSION = false;
            };
          }
        '';

        type = types.submodule {
          options = {
            log = {
              LEVEL = mkOption {
                default = "Info";
                description = "General log level.";

                type = types.enum [
                  "Trace"
                  "Debug"
                  "Info"
                  "Warn"
                  "Error"
                  "Critical"
                ];
              };

              ROOT_PATH = mkOption {
                default = "${cfg.stateDir}/log";
                defaultText = literalExpression ''"''${config.${opt.stateDir}}/log"'';
                description = "Root path for log files.";
                type = types.str;
              };
            };

            server = {
              DISABLE_SSH = mkOption {
                default = false;
                description = "Disable external SSH feature.";
                type = types.bool;
              };

              DOMAIN = mkOption {
                default = "localhost";
                description = "Domain name of your server.";
                type = types.str;
              };

              HTTP_ADDR = mkOption {
                default =
                  if lib.hasSuffix "+unix" cfg.settings.server.PROTOCOL then
                    "/run/forgejo/forgejo.sock"
                  else
                    "0.0.0.0";

                defaultText = literalExpression ''if lib.hasSuffix "+unix" cfg.settings.server.PROTOCOL then "/run/forgejo/forgejo.sock" else "0.0.0.0"'';
                description = "Listen address. Must be a path when using a unix socket.";
                type = types.either types.str types.path;
              };

              HTTP_PORT = mkOption {
                default = 3000;
                description = "Listen port. Ignored when using a unix socket.";
                type = types.port;
              };

              PROTOCOL = mkOption {
                default = "http";
                description = ''Listen protocol. `+unix` means "over unix", not "in addition to."'';

                type = types.enum [
                  "http"
                  "https"
                  "fcgi"
                  "http+unix"
                  "fcgi+unix"
                ];
              };

              ROOT_URL = mkOption {
                default = "http://${cfg.settings.server.DOMAIN}:${toString cfg.settings.server.HTTP_PORT}/";
                defaultText = literalExpression ''"http://''${config.services.forgejo.settings.server.DOMAIN}:''${toString config.services.forgejo.settings.server.HTTP_PORT}/"'';
                description = "Full public URL of Forgejo server.";
                type = types.str;
              };

              SSH_PORT = mkOption {
                default = 22;

                description = ''
                  SSH port displayed in clone URL.
                  The option is required to configure a service when the external visible port
                  differs from the local listening port i.e. if port forwarding is used.
                '';

                example = 2222;
                type = types.port;
              };

              STATIC_ROOT_PATH = mkOption {
                default = cfg.package.data;
                defaultText = literalExpression "config.${opt.package}.data";
                description = "Upper level of template and static files path.";
                example = "/var/lib/forgejo/data";
                type = types.either types.str types.path;
              };
            };

            session = {
              COOKIE_SECURE = mkOption {
                default = false;

                description = ''
                  Marks session cookies as "secure" as a hint for browsers to only send
                  them via HTTPS. This option is recommend, if Forgejo is being served over HTTPS.
                '';

                type = types.bool;
              };
            };
          };

          freeformType = format.type;
        };
      };

      stateDir = mkOption {
        default = "/var/lib/forgejo";
        description = "Forgejo data directory.";
        type = types.str;
      };

      useWizard = mkOption {
        default = false;

        description = ''
          Whether to use the built-in installation wizard instead of
          declaratively managing the {file}`app.ini` config file in nix.
        '';

        type = types.bool;
      };

      user = mkOption {
        default = "forgejo";
        description = "User account under which Forgejo runs.";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.database.createDatabase -> useSqlite || cfg.database.user == cfg.user;
        message = "services.forgejo.database.user must match services.forgejo.user if the database is to be automatically provisioned";
      }
      {
        assertion = cfg.database.createDatabase && usePostgresql -> cfg.database.user == cfg.database.name;

        message = ''
          When creating a database via NixOS, the db user and db name must be equal!
          If you already have an existing DB+user and this assertion is new, you can safely set
          `services.forgejo.createDatabase` to `false` because removal of `ensureUsers`
          and `ensureDatabases` doesn't have any effect.
        '';
      }
    ];

    services.forgejo.secrets = {
      database = mkIf (cfg.database.passwordFile != null) {
        PASSWD = cfg.database.passwordFile;
      };

      oauth2 = {
        JWT_SECRET = "${cfg.customDir}/conf/oauth2_jwt_secret";
      };

      security = {
        INTERNAL_TOKEN = "${cfg.customDir}/conf/internal_token";
        SECRET_KEY = "${cfg.customDir}/conf/secret_key";
      };

      server = mkIf cfg.lfs.enable {
        LFS_JWT_SECRET = "${cfg.customDir}/conf/lfs_jwt_secret";
      };
    };

    services.forgejo.settings = {
      DEFAULT = {
        RUN_MODE = mkDefault "prod";
        RUN_USER = mkDefault cfg.user;
        WORK_PATH = mkDefault cfg.stateDir;
      };

      database = mkMerge [
        {
          DB_TYPE = cfg.database.type;
        }
        (mkIf (useMysql || usePostgresql) {
          HOST =
            if cfg.database.socket != null then
              cfg.database.socket
            else
              cfg.database.host + ":" + toString cfg.database.port;

          NAME = cfg.database.name;
          USER = cfg.database.user;
        })
        (mkIf useSqlite {
          PATH = cfg.database.path;
        })
        (mkIf usePostgresql {
          SSL_MODE = "disable";
        })
      ];

      lfs = mkIf cfg.lfs.enable {
        PATH = cfg.lfs.contentDir;
      };

      repository = {
        ROOT = cfg.repositoryRoot;
      };

      security = {
        INSTALL_LOCK = true;
      };

      server = mkIf cfg.lfs.enable {
        LFS_START_SERVER = true;
      };

      session = {
        COOKIE_NAME = mkDefault "session";
      };
    };

    services.mysql = optionalAttrs (useMysql && cfg.database.createDatabase) {
      enable = mkDefault true;
      package = mkDefault pkgs.mariadb;
      ensureDatabases = [ cfg.database.name ];

      ensureUsers = [
        {
          ensurePermissions = {
            "${cfg.database.name}.*" = "ALL PRIVILEGES";
          };

          name = cfg.database.user;
        }
      ];
    };

    services.openssh.settings.AcceptEnv = mkIf (!cfg.settings.server.START_SSH_SERVER or false) [
      "GIT_PROTOCOL"
    ];

    services.postgresql = optionalAttrs (usePostgresql && cfg.database.createDatabase) {
      enable = mkDefault true;
      ensureDatabases = [ cfg.database.name ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = cfg.database.user;
        }
      ];
    };

    systemd.services.forgejo = {
      after = [
        "network.target"
      ]
      ++ optionals usePostgresql [
        "postgresql.target"
      ]
      ++ optionals useMysql [
        "mysql.service"
      ]
      ++ optionals (!cfg.useWizard) [
        "forgejo-secrets.service"
      ];

      description = "Forgejo (Beyond coding. We forge.)";

      environment = {
        FORGEJO_CUSTOM = cfg.customDir;
        FORGEJO_WORK_DIR = cfg.stateDir;
        HOME = cfg.stateDir;
        USER = cfg.user;
      }
      // lib.listToAttrs (map (e: lib.nameValuePair e.env "%d/${e.env}") secrets);

      path = [
        cfg.package
        pkgs.git
        pkgs.gnupg
      ];

      # In older versions the secret naming for JWT was kind of confusing.
      # The file jwt_secret hold the value for LFS_JWT_SECRET and JWT_SECRET
      # wasn't persistent at all.
      # To fix that, there is now the file oauth2_jwt_secret containing the
      # values for JWT_SECRET and the file jwt_secret gets renamed to
      # lfs_jwt_secret.
      # We have to consider this to stay compatible with older installations.
      preStart = ''
        ${optionalString (!cfg.useWizard) ''
          function forgejo_setup {
            config='${cfg.customDir}/conf/app.ini'
            cp -f '${format.generate "app.ini" cfg.settings}' "$config"

            chmod u+w "$config"
            ${lib.getExe' cfg.package "environment-to-ini"} --config "$config"
            chmod u-w "$config"
          }
          (umask 027; forgejo_setup)
        ''}

        # run migrations/init the database
        ${exe} migrate

        # update all hooks' binary paths
        ${exe} admin regenerate hooks

        # update command option in authorized_keys
        if [ -r ${cfg.stateDir}/.ssh/authorized_keys ]
        then
          ${exe} admin regenerate keys
        fi
      '';

      requires =
        optionals (cfg.database.createDatabase && usePostgresql) [
          "postgresql.target"
        ]
        ++ optionals (cfg.database.createDatabase && useMysql) [
          "mysql.service"
        ]
        ++ optionals (!cfg.useWizard) [
          "forgejo-secrets.service"
        ];

      serviceConfig = {
        # Capabilities
        CapabilityBoundingSet = "";
        ExecStart = "${exe} web --pid /run/forgejo/forgejo.pid";
        Group = cfg.group;
        # cfg.secrets
        LoadCredential = map (e: "${e.env}:${e.path}") secrets;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        # Security
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        # Proc filesystem
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        # Sandboxing
        ProtectSystem = "strict";

        # Access write directories
        ReadWritePaths = [
          cfg.customDir
          cfg.dump.backupDir
          cfg.repositoryRoot
          cfg.stateDir
          cfg.lfs.contentDir
        ];

        RemoveIPC = true;
        Restart = "always";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        # Runtime directory and mode
        RuntimeDirectory = "forgejo";
        RuntimeDirectoryMode = "0755";
        # System Call Filtering
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "~@cpu-emulation @debug @keyring @mount @obsolete @privileged @setuid"
          "setrlimit"
        ];

        Type = "notify";
        UMask = "0027";
        User = cfg.user;
        WorkingDirectory = cfg.stateDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.forgejo-dump = mkIf cfg.dump.enable {
      after = [ "forgejo.service" ];
      description = "forgejo dump";

      environment = {
        FORGEJO_CUSTOM = cfg.customDir;
        FORGEJO_WORK_DIR = cfg.stateDir;
        HOME = cfg.stateDir;
        USER = cfg.user;
      };

      path = [ cfg.package ];

      serviceConfig = {
        ExecStart =
          "${exe} dump --type ${cfg.dump.type}"
          + optionalString (cfg.dump.file != null) " --file ${cfg.dump.file}";

        Type = "oneshot";
        User = cfg.user;
        WorkingDirectory = cfg.dump.backupDir;
      };
    };

    systemd.services.forgejo-secrets = mkIf (!cfg.useWizard) {
      description = "Forgejo secret bootstrap helper";

      script = ''
        if [ ! -s '${cfg.secrets.security.SECRET_KEY}' ]; then
            ${exe} generate secret SECRET_KEY > '${cfg.secrets.security.SECRET_KEY}'
        fi

        if [ ! -s '${cfg.secrets.oauth2.JWT_SECRET}' ]; then
            ${exe} generate secret JWT_SECRET > '${cfg.secrets.oauth2.JWT_SECRET}'
        fi

        ${optionalString cfg.lfs.enable ''
          if [ ! -s '${cfg.secrets.server.LFS_JWT_SECRET}' ]; then
              ${exe} generate secret LFS_JWT_SECRET > '${cfg.secrets.server.LFS_JWT_SECRET}'
          fi
        ''}

        if [ ! -s '${cfg.secrets.security.INTERNAL_TOKEN}' ]; then
            ${exe} generate secret INTERNAL_TOKEN > '${cfg.secrets.security.INTERNAL_TOKEN}'
        fi
      '';

      serviceConfig = {
        Group = cfg.group;
        ReadWritePaths = [ cfg.customDir ];
        RemainAfterExit = true;
        Type = "oneshot";
        UMask = "0077";
        User = cfg.user;
      };
    };

    systemd.timers.forgejo-dump = mkIf cfg.dump.enable {
      description = "Forgejo dump timer";
      partOf = [ "forgejo-dump.service" ];
      timerConfig.OnCalendar = cfg.dump.interval;
      wantedBy = [ "timers.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dump.backupDir}' 0750 ${cfg.user} ${cfg.group} ${cfg.dump.age} -"
      "z '${cfg.dump.backupDir}' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.repositoryRoot}' 0750 ${cfg.user} ${cfg.group} - -"
      "z '${cfg.repositoryRoot}' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.stateDir}' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.stateDir}/conf' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.customDir}' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.customDir}/conf' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.stateDir}/data' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.stateDir}/log' 0750 ${cfg.user} ${cfg.group} - -"
      "z '${cfg.stateDir}' 0750 ${cfg.user} ${cfg.group} - -"
      "z '${cfg.stateDir}/.ssh' 0700 ${cfg.user} ${cfg.group} - -"
      "z '${cfg.stateDir}/conf' 0750 ${cfg.user} ${cfg.group} - -"
      "z '${cfg.customDir}' 0750 ${cfg.user} ${cfg.group} - -"
      "z '${cfg.customDir}/conf' 0750 ${cfg.user} ${cfg.group} - -"
      "z '${cfg.stateDir}/data' 0750 ${cfg.user} ${cfg.group} - -"
      "z '${cfg.stateDir}/log' 0750 ${cfg.user} ${cfg.group} - -"

      # If we have a folder or symlink with Forgejo locales, remove it
      # And symlink the current Forgejo locales in place
      "L+ '${cfg.stateDir}/conf/locale' - - - - ${cfg.package.out}/locale"

    ]
    ++ optionals cfg.lfs.enable [
      "d '${cfg.lfs.contentDir}' 0750 ${cfg.user} ${cfg.group} - -"
      "z '${cfg.lfs.contentDir}' 0750 ${cfg.user} ${cfg.group} - -"
    ];

    users.groups = mkIf (cfg.group == "forgejo") {
      forgejo = { };
    };

    users.users = mkIf (cfg.user == "forgejo") {
      forgejo = {
        group = cfg.group;
        home = cfg.stateDir;
        isSystemUser = true;
        useDefaultShell = true;
      };
    };
  };

  meta.doc = ./forgejo.md;
  meta.teams = [ lib.teams.forgejo ];
}
