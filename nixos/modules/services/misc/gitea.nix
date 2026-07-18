{
  config,
  lib,
  pkgs,
  options,
  ...
}:

with lib;

let
  cfg = config.services.gitea;
  opt = options.services.gitea;
  exe = lib.getExe cfg.package;
  pg = config.services.postgresql;
  useMysql = cfg.database.type == "mysql";
  usePostgresql = cfg.database.type == "postgres";
  useSqlite = cfg.database.type == "sqlite3";
  format = pkgs.formats.ini { };
  configFile = pkgs.writeText "app.ini" ''
    APP_NAME = ${cfg.appName}
    RUN_USER = ${cfg.user}
    RUN_MODE = prod
    WORK_PATH = ${cfg.stateDir}

    ${generators.toINI { } cfg.settings}

    ${optionalString (cfg.extraConfig != null) cfg.extraConfig}
  '';

  inherit (cfg.settings) mailer;
  useSendmail = mailer.ENABLED && mailer.PROTOCOL == "sendmail";
in

{
  imports = [
    (mkRenamedOptionModule
      [ "services" "gitea" "cookieSecure" ]
      [ "services" "gitea" "settings" "session" "COOKIE_SECURE" ]
    )
    (mkRenamedOptionModule
      [ "services" "gitea" "disableRegistration" ]
      [ "services" "gitea" "settings" "service" "DISABLE_REGISTRATION" ]
    )
    (mkRenamedOptionModule
      [ "services" "gitea" "domain" ]
      [ "services" "gitea" "settings" "server" "DOMAIN" ]
    )
    (mkRenamedOptionModule
      [ "services" "gitea" "httpAddress" ]
      [ "services" "gitea" "settings" "server" "HTTP_ADDR" ]
    )
    (mkRenamedOptionModule
      [ "services" "gitea" "httpPort" ]
      [ "services" "gitea" "settings" "server" "HTTP_PORT" ]
    )
    (mkRenamedOptionModule
      [ "services" "gitea" "log" "level" ]
      [ "services" "gitea" "settings" "log" "LEVEL" ]
    )
    (mkRenamedOptionModule
      [ "services" "gitea" "log" "rootPath" ]
      [ "services" "gitea" "settings" "log" "ROOT_PATH" ]
    )
    (mkRenamedOptionModule
      [ "services" "gitea" "rootUrl" ]
      [ "services" "gitea" "settings" "server" "ROOT_URL" ]
    )
    (mkRenamedOptionModule
      [ "services" "gitea" "ssh" "clonePort" ]
      [ "services" "gitea" "settings" "server" "SSH_PORT" ]
    )
    (mkRenamedOptionModule
      [ "services" "gitea" "staticRootPath" ]
      [ "services" "gitea" "settings" "server" "STATIC_ROOT_PATH" ]
    )

    (mkChangedOptionModule
      [ "services" "gitea" "enableUnixSocket" ]
      [ "services" "gitea" "settings" "server" "PROTOCOL" ]
      (config: if config.services.gitea.enableUnixSocket then "http+unix" else "http")
    )

    (mkRemovedOptionModule [ "services" "gitea" "ssh" "enable" ]
      "It has been migrated into freeform setting services.gitea.settings.server.DISABLE_SSH. Keep in mind that the setting is inverted."
    )
    (mkRemovedOptionModule [
      "services"
      "gitea"
      "useWizard"
    ] "Has been removed because it was broken and lacked automated testing.")
  ];

  options = {
    services.gitea = {
      enable = mkOption {
        default = false;
        description = "Enable Gitea Service.";
        type = types.bool;
      };

      package = mkPackageOption pkgs "gitea" { };

      appName = mkOption {
        default = "gitea: Gitea Service";
        description = "Application name.";
        type = types.str;
      };

      camoHmacKeyFile = mkOption {
        default = null;
        description = "Path to a file containing the camo HMAC key.";
        example = "/var/lib/secrets/gitea/camoHmacKey";
        type = types.nullOr types.str;
      };

      captcha = {
        enable = mkOption {
          default = false;

          description = ''
            Enables Gitea to display a CAPTCHA challenge on registration.
          '';

          type = types.bool;
        };

        requireForExternalRegistration = mkOption {
          default = false;
          description = "Displays a CAPTCHA challenge for users that register externally.";
          example = true;
          type = types.bool;
        };

        requireForLogin = mkOption {
          default = false;
          description = "Displays a CAPTCHA challenge whenever a user logs in.";
          example = true;
          type = types.bool;
        };

        secretFile = mkOption {
          default = null;
          description = "Path to a file containing the CAPTCHA secret key.";
          example = "/var/lib/secrets/gitea/captcha_secret";
          type = types.nullOr types.str;
        };

        siteKey = mkOption {
          default = null;
          description = "CAPTCHA site key to use for Gitea.";
          example = "my_site_key";
          type = types.nullOr types.str;
        };

        type = mkOption {
          default = "image";
          description = "The type of CAPTCHA to use for Gitea.";
          example = "recaptcha";

          type = types.enum [
            "image"
            "recaptcha"
            "hcaptcha"
            "mcaptcha"
            "cfturnstile"
          ];
        };

        url = mkOption {
          default = null;
          description = "CAPTCHA url to use for Gitea. Only relevant for `recaptcha` and `mcaptcha`.";
          example = "https://google.com/recaptcha";
          type = types.nullOr types.str;
        };
      };

      customDir = mkOption {
        default = "${cfg.stateDir}/custom";
        defaultText = literalExpression ''"''${config.${opt.stateDir}}/custom"'';
        description = "Gitea custom directory. Used for config, custom templates and other options.";
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
          default = "gitea";
          description = "Database name.";
          type = types.str;
        };

        password = mkOption {
          default = "";

          description = ''
            The password corresponding to {option}`database.user`.
            Warning: this is stored in cleartext in the Nix store!
            Use {option}`database.passwordFile` instead.
          '';

          type = types.str;
        };

        passwordFile = mkOption {
          default = null;

          description = ''
            A file containing the password corresponding to
            {option}`database.user`.
          '';

          example = "/run/keys/gitea-dbpassword";
          type = types.nullOr types.path;
        };

        path = mkOption {
          default = "${cfg.stateDir}/data/gitea.db";
          defaultText = literalExpression ''"''${config.${opt.stateDir}}/data/gitea.db"'';
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
          default = "gitea";
          description = "Database user.";
          type = types.str;
        };
      };

      dump = {
        enable = mkOption {
          default = false;

          description = ''
            Enable a timer that runs gitea dump to generate backup-files of the
            current gitea database and repositories.
          '';

          type = types.bool;
        };

        backupDir = mkOption {
          default = "${cfg.stateDir}/dump";
          defaultText = literalExpression ''"''${config.${opt.stateDir}}/dump"'';
          description = "Path to the dump files.";
          type = types.str;
        };

        file = mkOption {
          default = null;
          description = "Filename to be used for the dump. If `null` a default name is chosen by gitea.";
          example = "gitea-dump";
          type = types.nullOr types.str;
        };

        interval = mkOption {
          default = "04:31";

          description = ''
            Run a gitea dump at this interval. Runs by default at 04:31 every day.

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
            "rar"
            "tar"
            "sz"
            "tar.gz"
            "tar.xz"
            "tar.bz2"
            "tar.br"
            "tar.lz4"
            "tar.zst"
          ];
        };
      };

      extraConfig = mkOption {
        default = null;
        description = "Configuration lines appended to the generated gitea configuration file.";
        type = with types; nullOr str;
      };

      group = mkOption {
        default = "gitea";
        description = "Group under which gitea runs.";
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

      mailerPasswordFile = mkOption {
        default = null;
        description = "Path to a file containing the SMTP password.";
        example = "/var/lib/secrets/gitea/mailpw";
        type = types.nullOr types.str;
      };

      metricsTokenFile = mkOption {
        default = null;
        description = "Path to a file containing the metrics authentication token.";
        example = "/var/lib/secrets/gitea/metrics_token";
        type = types.nullOr types.str;
      };

      minioAccessKeyId = mkOption {
        default = null;
        description = "Path to a file containing the Minio access key id.";
        example = "/var/lib/secrets/gitea/minio_access_key_id";
        type = types.nullOr types.str;
      };

      minioSecretAccessKey = mkOption {
        default = null;
        description = "Path to a file containing the Minio secret access key.";
        example = "/var/lib/secrets/gitea/minio_secret_access_key";
        type = types.nullOr types.str;
      };

      repositoryRoot = mkOption {
        default = "${cfg.stateDir}/repositories";
        defaultText = literalExpression ''"''${config.${opt.stateDir}}/repositories"'';
        description = "Path to the git repositories.";
        type = types.str;
      };

      settings = mkOption {
        default = { };

        description = ''
          Gitea configuration. Refer to <https://docs.gitea.io/en-us/config-cheat-sheet/>
          for details on supported values.
        '';

        example = literalExpression ''
          {
            "cron.sync_external_users" = {
              RUN_AT_START = true;
              SCHEDULE = "@every 24h";
              UPDATE_EXISTING = true;
            };
            mailer = {
              ENABLED = true;
              PROTOCOL = "smtp+starttls";
              SMTP_ADDR = "smtp.example.org";
              SMTP_PORT = "587";
              FROM = "Gitea Service <do-not-reply@example.org>";
              USER = "do-not-reply@example.org";
            };
            other = {
              SHOW_FOOTER_VERSION = false;
            };
          }
        '';

        type = types.submodule (
          { config, options, ... }:
          {
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

              mailer = {
                ENABLED = lib.mkOption {
                  default = false;
                  description = "Whether to use an email service to send notifications.";
                  type = lib.types.bool;
                };

                PROTOCOL = lib.mkOption {
                  default = null;
                  description = "Which mail server protocol to use.";

                  type = lib.types.enum [
                    null
                    "smtp"
                    "smtps"
                    "smtp+starttls"
                    "smtp+unix"
                    "sendmail"
                    "dummy"
                  ];
                };

                SENDMAIL_PATH = lib.mkOption {
                  # somewhat duplicated with useSendmail but cannot be deduped because of infinite recursion
                  default =
                    if config.mailer.ENABLED && config.mailer.PROTOCOL == "sendmail" then
                      "/run/wrappers/bin/sendmail"
                    else
                      "sendmail";

                  defaultText = lib.literalExpression ''if config.${options.mailer.ENABLED} && config.${options.mailer.PROTOCOL} == "sendmail" then "/run/wrappers/bin/sendmail" else "sendmail"'';
                  description = "Path to sendmail binary or script.";
                  type = lib.types.str;
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
                    if lib.hasSuffix "+unix" cfg.settings.server.PROTOCOL then "/run/gitea/gitea.sock" else "0.0.0.0";

                  defaultText = literalExpression ''if lib.hasSuffix "+unix" cfg.settings.server.PROTOCOL then "/run/gitea/gitea.sock" else "0.0.0.0"'';
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
                  defaultText = literalExpression ''"http://''${config.services.gitea.settings.server.DOMAIN}:''${toString config.services.gitea.settings.server.HTTP_PORT}/"'';
                  description = "Full public URL of gitea server.";
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
                  example = "/var/lib/gitea/data";
                  type = types.either types.str types.path;
                };
              };

              service = {
                DISABLE_REGISTRATION = mkEnableOption "the registration lock" // {
                  description = ''
                    By default any user can create an account on this `gitea` instance.
                    This can be disabled by using this option.

                    *Note:* please keep in mind that this should be added after the initial
                    deploy as the first registered user will be the administrator.
                  '';
                };
              };

              session = {
                COOKIE_SECURE = mkOption {
                  default = false;

                  description = ''
                    Marks session cookies as "secure" as a hint for browsers to only send
                    them via HTTPS. This option is recommend, if gitea is being served over HTTPS.
                  '';

                  type = types.bool;
                };
              };
            };

            freeformType = format.type;
          }
        );
      };

      stateDir = mkOption {
        default = "/var/lib/gitea";
        description = "Gitea data directory.";
        type = types.str;
      };

      user = mkOption {
        default = "gitea";
        description = "User account under which gitea runs.";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.database.createDatabase -> useSqlite || cfg.database.user == cfg.user;
        message = "services.gitea.database.user must match services.gitea.user if the database is to be automatically provisioned";
      }
      {
        assertion = cfg.database.createDatabase && usePostgresql -> cfg.database.user == cfg.database.name;

        message = ''
          When creating a database via NixOS, the db user and db name must be equal!
          If you already have an existing DB+user and this assertion is new, you can safely set
          `services.gitea.createDatabase` to `false` because removal of `ensureUsers`
          and `ensureDatabases` doesn't have any effect.
        '';
      }
      {
        assertion =
          cfg.captcha.enable
          -> cfg.captcha.type != "image"
          -> (cfg.captcha.secretFile != null && cfg.captcha.siteKey != null);

        message = ''
          Using a CAPTCHA service that is not `image` requires providing a CAPTCHA secret through
          the `captcha.secretFile` option and a CAPTCHA site key through the `captcha.siteKey` option.
        '';
      }
      {
        assertion =
          cfg.captcha.url != null
          -> (builtins.elem cfg.captcha.type [
            "mcaptcha"
            "recaptcha"
          ]);

        message = ''
          `captcha.url` is only relevant when `captcha.type` is `mcaptcha` or `recaptcha`.
        '';
      }
    ];

    # Create database passwordFile default when password is configured.
    services.gitea.database.passwordFile = mkDefault (
      toString (
        pkgs.writeTextFile {
          name = "gitea-database-password";
          text = cfg.database.password;
        }
      )
    );

    services.gitea.settings =
      let
        captchaPrefix = optionalString cfg.captcha.enable (
          {
            cfturnstile = "CF_TURNSTILE";
            hcaptcha = "HCAPTCHA";
            image = "IMAGE";
            mcaptcha = "MCAPTCHA";
            recaptcha = "RECAPTCHA";
          }
          ."${cfg.captcha.type}"
        );
      in
      {
        camo = mkIf (cfg.camoHmacKeyFile != null) {
          HMAC_KEY = "#hmackey#";
        };

        "cron.update_checker".ENABLED = lib.mkDefault false;

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
            PASSWD = "#dbpass#";
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

        mailer = mkIf (cfg.mailerPasswordFile != null) {
          PASSWD = "#mailerpass#";
        };

        metrics = mkIf (cfg.metricsTokenFile != null) {
          TOKEN = "#metricstoken#";
        };

        oauth2 = {
          JWT_SECRET = "#oauth2jwtsecret#";
        };

        packages.CHUNKED_UPLOAD_PATH = "${cfg.stateDir}/tmp/package-upload";

        repository = {
          ROOT = cfg.repositoryRoot;
        };

        security = {
          INSTALL_LOCK = true;
          INTERNAL_TOKEN = "#internaltoken#";
          SECRET_KEY = "#secretkey#";
        };

        server = mkIf cfg.lfs.enable {
          LFS_JWT_SECRET = "#lfsjwtsecret#";
          LFS_START_SERVER = true;
        };

        service = mkIf cfg.captcha.enable (mkMerge [
          {
            CAPTCHA_TYPE = cfg.captcha.type;
            ENABLE_CAPTCHA = true;
            REQUIRE_CAPTCHA_FOR_LOGIN = cfg.captcha.requireForLogin;
            REQUIRE_EXTERNAL_REGISTRATION_CAPTCHA = cfg.captcha.requireForExternalRegistration;
          }
          (mkIf (cfg.captcha.secretFile != null) {
            "${captchaPrefix}_SECRET" = "#captchasecret#";
          })
          (mkIf (cfg.captcha.siteKey != null) {
            "${captchaPrefix}_SITEKEY" = cfg.captcha.siteKey;
          })
          (mkIf (cfg.captcha.url != null) {
            "${captchaPrefix}_URL" = cfg.captcha.url;
          })
        ]);

        session = {
          COOKIE_NAME = lib.mkDefault "session";
        };

        storage = mkMerge [
          (mkIf (cfg.minioAccessKeyId != null) {
            MINIO_ACCESS_KEY_ID = "#minioaccesskeyid#";
          })
          (mkIf (cfg.minioSecretAccessKey != null) {
            MINIO_SECRET_ACCESS_KEY = "#miniosecretaccesskey#";
          })
        ];
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

    systemd.services.gitea = {
      after = [
        "network.target"
      ]
      ++ optional usePostgresql "postgresql.target"
      ++ optional useMysql "mysql.service";

      description = "gitea";

      environment = {
        GITEA_CUSTOM = cfg.customDir;
        GITEA_WORK_DIR = cfg.stateDir;
        HOME = cfg.stateDir;
        USER = cfg.user;
      };

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
      preStart =
        let
          runConfig = "${cfg.customDir}/conf/app.ini";
          secretKey = "${cfg.customDir}/conf/secret_key";
          oauth2JwtSecret = "${cfg.customDir}/conf/oauth2_jwt_secret";
          oldLfsJwtSecret = "${cfg.customDir}/conf/jwt_secret"; # old file for LFS_JWT_SECRET
          lfsJwtSecret = "${cfg.customDir}/conf/lfs_jwt_secret"; # new file for LFS_JWT_SECRET
          internalToken = "${cfg.customDir}/conf/internal_token";
          replaceSecretBin = "${pkgs.replace-secret}/bin/replace-secret";
        in
        ''
          # copy custom configuration and generate random secrets if needed
          function gitea_setup {
            cp -f '${configFile}' '${runConfig}'

            if [ ! -s '${secretKey}' ]; then
                ${exe} generate secret SECRET_KEY > '${secretKey}'
            fi

            # Migrate LFS_JWT_SECRET filename
            if [[ -s '${oldLfsJwtSecret}' && ! -s '${lfsJwtSecret}' ]]; then
                mv '${oldLfsJwtSecret}' '${lfsJwtSecret}'
            fi

            if [ ! -s '${oauth2JwtSecret}' ]; then
                ${exe} generate secret JWT_SECRET > '${oauth2JwtSecret}'
            fi

            ${lib.optionalString cfg.lfs.enable ''
              if [ ! -s '${lfsJwtSecret}' ]; then
                  ${exe} generate secret LFS_JWT_SECRET > '${lfsJwtSecret}'
              fi
            ''}

            if [ ! -s '${internalToken}' ]; then
                ${exe} generate secret INTERNAL_TOKEN > '${internalToken}'
            fi

            chmod u+w '${runConfig}'
            ${replaceSecretBin} '#secretkey#' '${secretKey}' '${runConfig}'
            ${replaceSecretBin} '#dbpass#' '${cfg.database.passwordFile}' '${runConfig}'
            ${replaceSecretBin} '#oauth2jwtsecret#' '${oauth2JwtSecret}' '${runConfig}'
            ${replaceSecretBin} '#internaltoken#' '${internalToken}' '${runConfig}'

            ${lib.optionalString cfg.lfs.enable ''
              ${replaceSecretBin} '#lfsjwtsecret#' '${lfsJwtSecret}' '${runConfig}'
            ''}

            ${lib.optionalString (cfg.camoHmacKeyFile != null) ''
              ${replaceSecretBin} '#hmackey#' '${cfg.camoHmacKeyFile}' '${runConfig}'
            ''}

            ${lib.optionalString (cfg.mailerPasswordFile != null) ''
              ${replaceSecretBin} '#mailerpass#' '${cfg.mailerPasswordFile}' '${runConfig}'
            ''}

            ${lib.optionalString (cfg.metricsTokenFile != null) ''
              ${replaceSecretBin} '#metricstoken#' '${cfg.metricsTokenFile}' '${runConfig}'
            ''}

            ${lib.optionalString (cfg.minioAccessKeyId != null) ''
              ${replaceSecretBin} '#minioaccesskeyid#' '${cfg.minioAccessKeyId}' '${runConfig}'
            ''}
            ${lib.optionalString (cfg.minioSecretAccessKey != null) ''
              ${replaceSecretBin} '#miniosecretaccesskey#' '${cfg.minioSecretAccessKey}' '${runConfig}'
            ''}

            ${lib.optionalString (cfg.captcha.secretFile != null) ''
              ${replaceSecretBin} '#captchasecret#' '${cfg.captcha.secretFile}' '${runConfig}'
            ''}
            chmod u-w '${runConfig}'
          }
          (umask 027; gitea_setup)

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
        optional (cfg.database.createDatabase && usePostgresql) "postgresql.target"
        ++ optional (cfg.database.createDatabase && useMysql) "mysql.service";

      serviceConfig = {
        # Sandboxing
        CapabilityBoundingSet = "";
        ExecStart = "${exe} web --pid /run/gitea/gitea.pid";
        Group = cfg.group;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = !useSendmail;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = !useSendmail;
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
        ProtectSystem = "strict";

        # Access write directories
        ReadWritePaths = [
          cfg.customDir
          cfg.dump.backupDir
          cfg.repositoryRoot
          cfg.stateDir
          cfg.lfs.contentDir
        ]
        ++ lib.optional (useSendmail && config.services.postfix.enable) "/var/lib/postfix/queue/maildrop";

        RemoveIPC = true;
        Restart = "always";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ]
        ++ lib.optional (useSendmail && config.services.postfix.enable) "AF_NETLINK";

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        # Runtime directory and mode
        RuntimeDirectory = "gitea";
        RuntimeDirectoryMode = "0755";
        # System Call Filtering
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "~@cpu-emulation @debug @keyring @mount @obsolete @setuid"
          "setrlimit"
        ]
        ++ lib.optionals (!useSendmail) [
          "~@privileged"
        ];

        # one mid size deployments, Gitea already gets killed when doing DB migrations
        TimeoutStartSec = "3m";
        Type = "notify";
        UMask = "0027";
        User = cfg.user;
        WatchdogSec = 30;
        WorkingDirectory = cfg.stateDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.gitea-dump = mkIf cfg.dump.enable {
      after = [ "gitea.service" ];
      description = "gitea dump";

      environment = {
        GITEA_CUSTOM = cfg.customDir;
        GITEA_WORK_DIR = cfg.stateDir;
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

    systemd.timers.gitea-dump = mkIf cfg.dump.enable {
      description = "Update timer for gitea-dump";
      partOf = [ "gitea-dump.service" ];
      timerConfig.OnCalendar = cfg.dump.interval;
      wantedBy = [ "timers.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dump.backupDir}' 0750 ${cfg.user} ${cfg.group} - -"
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

      # If we have a folder or symlink with gitea locales, remove it
      # And symlink the current gitea locales in place
      "L+ '${cfg.stateDir}/conf/locale' - - - - ${cfg.package.out}/locale"

    ]
    ++ lib.optionals cfg.lfs.enable [
      "d '${cfg.lfs.contentDir}' 0750 ${cfg.user} ${cfg.group} - -"
      "z '${cfg.lfs.contentDir}' 0750 ${cfg.user} ${cfg.group} - -"
    ];

    users.groups = mkIf (cfg.group == "gitea") {
      gitea = { };
    };

    users.users = mkIf (cfg.user == "gitea") {
      gitea = {
        description = "Gitea Service";
        group = cfg.group;
        home = cfg.stateDir;
        isSystemUser = true;
        useDefaultShell = true;
      };
    };

    warnings =
      optional (cfg.database.password != "")
        "config.services.gitea.database.password will be stored as plaintext in the Nix store. Use database.passwordFile instead."
      ++ optional (cfg.extraConfig != null) ''
        services.gitea.`extraConfig` is deprecated, please use services.gitea.`settings`.
      ''
      ++ optional (lib.getName cfg.package == "forgejo") ''
        Running forgejo via services.gitea.package is no longer supported.
        Please use services.forgejo instead.
        See https://nixos.org/manual/nixos/unstable/#module-forgejo for migration instructions.
      '';
  };

  meta.maintainers = with lib.maintainers; [
    techknowlogick
    SuperSandro2000
  ];
}
