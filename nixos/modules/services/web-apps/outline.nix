{
  config,
  lib,
  pkgs,
  ...
}:

let
  defaultUser = "outline";
  cfg = config.services.outline;
  inherit (lib) mkRemovedOptionModule;
in
{
  imports = [
    (mkRemovedOptionModule [
      "services"
      "outline"
      "sequelizeArguments"
    ] "Database migration are run agains configurated database by outline directly")
  ];

  # See here for a reference of all the options:
  #   https://github.com/outline/outline/blob/v0.67.0/.env.sample
  #   https://github.com/outline/outline/blob/v0.67.0/app.json
  #   https://github.com/outline/outline/blob/v0.67.0/server/env.ts
  #   https://github.com/outline/outline/blob/v0.67.0/shared/types.ts
  # The order is kept the same here to make updating easier.
  options.services.outline = {
    enable = lib.mkEnableOption "outline";

    package = lib.mkOption {
      default = pkgs.outline;
      defaultText = lib.literalExpression "pkgs.outline";
      description = "Outline package to use.";

      example = lib.literalExpression ''
        pkgs.outline.overrideAttrs (super: {
          # Ignore the domain part in emails that come from OIDC. This is might
          # be helpful if you want multiple users with different email providers
          # to still land in the same team. Note that this effectively makes
          # Outline a single-team instance.
          patchPhase = ${"''"}
            sed -i 's/const domain = parts\.length && parts\[1\];/const domain = "example.com";/g' plugins/oidc/server/auth/oidc.ts
          ${"''"};
        })
      '';

      type = lib.types.package;
    };

    azureAuthentication = lib.mkOption {
      default = null;

      description = ''
        To configure Microsoft/Azure auth, you'll need to create an OAuth
        Client. See
        [the guide](https://wiki.generaloutline.com/share/dfa77e56-d4d2-4b51-8ff8-84ea6608faa4)
        for details on setting up your Azure App.
      '';

      type = lib.types.nullOr (
        lib.types.submodule {
          options = {
            clientId = lib.mkOption {
              description = "Authentication client identifier.";
              type = lib.types.str;
            };

            clientSecretFile = lib.mkOption {
              description = "File path containing the authentication secret.";
              type = lib.types.str;
            };

            resourceAppId = lib.mkOption {
              description = "Authentication application resource ID.";
              type = lib.types.str;
            };
          };
        }
      );
    };

    cdnUrl = lib.mkOption {
      default = "";

      description = ''
        If using a Cloudfront/Cloudflare distribution or similar it can be set
        using this option. This will cause paths to JavaScript files,
        stylesheets and images to be updated to the hostname defined here. In
        your CDN configuration the origin server should be set to public URL.
      '';

      type = lib.types.str;
    };

    concurrency = lib.mkOption {
      default = 1;

      description = ''
        How many processes should be spawned. For a rough estimate, divide your
        server's available memory by 512.
      '';

      type = lib.types.int;
    };

    databaseUrl = lib.mkOption {
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

    debugOutput = lib.mkOption {
      default = null;
      description = "Set this to `http` log HTTP requests.";
      type = lib.types.nullOr (lib.types.enum [ "http" ]);
    };

    defaultLanguage = lib.mkOption {
      default = "en_US";

      description = ''
        The default interface language. See
        [translate.getoutline.com](https://translate.getoutline.com/)
        for a list of available language codes and their rough percentage
        translated.
      '';

      type = lib.types.enum [
        "da_DK"
        "de_DE"
        "en_US"
        "es_ES"
        "fa_IR"
        "fr_FR"
        "it_IT"
        "ja_JP"
        "ko_KR"
        "nl_NL"
        "pl_PL"
        "pt_BR"
        "pt_PT"
        "ru_RU"
        "sv_SE"
        "th_TH"
        "vi_VN"
        "zh_CN"
        "zh_TW"
      ];
    };

    discordAuthentication = lib.mkOption {
      default = null;

      description = ''
        To configure Discord auth, you'll need to create an application at
        <https://discord.com/developers/applications/>

        See <https://docs.getoutline.com/s/hosting/doc/discord-g4JdWFFub6>
        for details on setting up your Discord app.
      '';

      type = lib.types.nullOr (
        lib.types.submodule {
          options = {
            clientId = lib.mkOption {
              description = "Authentication client identifier.";
              type = lib.types.str;
            };

            clientSecretFile = lib.mkOption {
              description = "File path containing the authentication secret.";
              type = lib.types.str;
            };

            serverId = lib.mkOption {
              default = "";

              description = ''
                Restrict logins to a specific server (optional, but recommended).
                You can find a Discord server's ID by right-clicking the server icon,
                and select “Copy Server ID”.
              '';

              type = lib.types.str;
            };

            serverRoles = lib.mkOption {
              default = "";
              description = "Optionally restrict logins to a comma-separated list of role IDs";
              type = lib.types.commas;
            };
          };
        }
      );
    };

    enableUpdateCheck = lib.mkOption {
      default = false;

      description = ''
        Have the installation check for updates by sending anonymized statistics
        to the maintainers.
      '';

      type = lib.types.bool;
    };

    forceHttps = lib.mkOption {
      default = true;

      description = ''
        Auto-redirect to HTTPS in production. The default is
        `true` but you may set this to `false`
        if you can be sure that SSL is terminated at an external loadbalancer.
      '';

      type = lib.types.bool;
    };

    googleAnalyticsId = lib.mkOption {
      default = null;

      description = ''
        Optionally enable Google Analytics to track page views in the knowledge
        base.
      '';

      type = lib.types.nullOr lib.types.str;
    };

    googleAuthentication = lib.mkOption {
      default = null;

      description = ''
        To configure Google auth, you'll need to create an OAuth Client ID at
        <https://console.cloud.google.com/apis/credentials>

        When configuring the Client ID, add an Authorized redirect URI to
        `https://[publicUrl]/auth/google.callback`.
      '';

      type = lib.types.nullOr (
        lib.types.submodule {
          options = {
            clientId = lib.mkOption {
              description = "Authentication client identifier.";
              type = lib.types.str;
            };

            clientSecretFile = lib.mkOption {
              description = "File path containing the authentication secret.";
              type = lib.types.str;
            };
          };
        }
      );
    };

    group = lib.mkOption {
      default = defaultUser;

      description = ''
        Group under which the service should run. If this is the default value,
        the group will be created.
      '';

      type = lib.types.str;
    };

    logo = lib.mkOption {
      default = null;

      description = ''
        Custom logo displayed on the authentication screen. This will be scaled
        to a height of 60px.
      '';

      type = lib.types.nullOr lib.types.str;
    };

    maximumImportSize = lib.mkOption {
      default = 5120000;

      description = ''
        The maximum size of document imports. Overriding this could be required
        if you have especially large Word documents with embedded imagery.
      '';

      type = lib.types.int;
    };

    oidcAuthentication = lib.mkOption {
      default = null;

      description = ''
        To configure generic OIDC auth, you'll need some kind of identity
        provider. See the documentation for whichever IdP you use to fill out
        all the fields. The redirect URL is
        `https://[publicUrl]/auth/oidc.callback`.
      '';

      type = lib.types.nullOr (
        lib.types.submodule {
          options = {
            authUrl = lib.mkOption {
              description = "OIDC authentication URL endpoint.";
              type = lib.types.str;
            };

            clientId = lib.mkOption {
              description = "Authentication client identifier.";
              type = lib.types.str;
            };

            clientSecretFile = lib.mkOption {
              description = "File path containing the authentication secret.";
              type = lib.types.str;
            };

            displayName = lib.mkOption {
              default = "OpenID";
              description = "Display name for OIDC authentication.";
              type = lib.types.str;
            };

            scopes = lib.mkOption {
              default = [
                "openid"
                "profile"
                "email"
              ];

              description = "OpenID authentication scopes.";
              type = lib.types.listOf lib.types.str;
            };

            tokenUrl = lib.mkOption {
              description = "OIDC token URL endpoint.";
              type = lib.types.str;
            };

            userinfoUrl = lib.mkOption {
              description = "OIDC userinfo URL endpoint.";
              type = lib.types.str;
            };

            usernameClaim = lib.mkOption {
              default = "preferred_username";

              description = ''
                Specify which claims to derive user information from. Supports any
                valid JSON path with the JWT payload
              '';

              type = lib.types.str;
            };
          };
        }
      );
    };

    port = lib.mkOption {
      default = 3000;
      description = "Listening port.";
      type = lib.types.port;
    };

    publicUrl = lib.mkOption {
      default = "http://localhost:3000";
      description = "The fully qualified, publicly accessible URL";
      type = lib.types.str;
    };

    rateLimiter.durationWindow = lib.mkOption {
      default = 60;
      description = "Length of a throttling window.";
      type = lib.types.int;
    };

    rateLimiter.enable = lib.mkEnableOption "rate limiter for the application web server";

    rateLimiter.requests = lib.mkOption {
      default = 5000;
      description = "Maximum number of requests in a throttling window.";
      type = lib.types.int;
    };

    redisUrl = lib.mkOption {
      default = "local";

      description = ''
        Connection to a redis server. If this needs to include credentials
        that shouldn't be world-readable in the Nix store, set an environment
        file on the systemd service and override the
        `REDIS_URL` entry. Pass the string
        `local` to setup a local Redis database.
      '';

      type = lib.types.str;
    };

    #
    # Required options
    #
    secretKeyFile = lib.mkOption {
      default = "/var/lib/outline/secret_key";

      description = ''
        File path that contains the application secret key. It must be 32
        bytes long and hex-encoded. If the file does not exist, a new key will
        be generated and saved here.
      '';

      type = lib.types.str;
    };

    sentryDsn = lib.mkOption {
      default = null;

      description = ''
        Optionally enable [Sentry](https://sentry.io/) to
        track errors and performance.
      '';

      type = lib.types.nullOr lib.types.str;
    };

    sentryTunnel = lib.mkOption {
      default = null;

      description = ''
        Optionally add a
        [Sentry proxy tunnel](https://docs.sentry.io/platforms/javascript/troubleshooting/#using-the-tunnel-option)
        for bypassing ad blockers in the UI.
      '';

      type = lib.types.nullOr lib.types.str;
    };

    #
    # Authentication
    #
    slackAuthentication = lib.mkOption {
      default = null;

      description = ''
        To configure Slack auth, you'll need to create an Application at
        <https://api.slack.com/apps>

        When configuring the Client ID, add a redirect URL under "OAuth & Permissions"
        to `https://[publicUrl]/auth/slack.callback`.
      '';

      type = lib.types.nullOr (
        lib.types.submodule {
          options = {
            clientId = lib.mkOption {
              description = "Authentication key.";
              type = lib.types.str;
            };

            secretFile = lib.mkOption {
              description = "File path containing the authentication secret.";
              type = lib.types.str;
            };
          };
        }
      );
    };

    slackIntegration = lib.mkOption {
      default = null;

      description = ''
        For a complete Slack integration with search and posting to channels
        this configuration is also needed. See here for details:
        <https://wiki.generaloutline.com/share/be25efd1-b3ef-4450-b8e5-c4a4fc11e02a>
      '';

      type = lib.types.nullOr (
        lib.types.submodule {
          options = {
            appId = lib.mkOption {
              description = "Application ID.";
              type = lib.types.str;
            };

            messageActions = lib.mkOption {
              default = true;
              description = "Whether to enable message actions.";
              type = lib.types.bool;
            };

            verificationTokenFile = lib.mkOption {
              description = "File path containing the verification token.";
              type = lib.types.str;
            };
          };
        }
      );
    };

    smtp = lib.mkOption {
      default = null;

      description = ''
        To support sending outgoing transactional emails such as
        "document updated" or "you've been invited" you'll need to provide
        authentication for an SMTP server.
      '';

      type = lib.types.nullOr (
        lib.types.submodule {
          options = {
            fromEmail = lib.mkOption {
              description = "Sender email in outgoing mail.";
              type = lib.types.str;
            };

            host = lib.mkOption {
              description = "Host name or IP address of the SMTP server.";
              type = lib.types.str;
            };

            passwordFile = lib.mkOption {
              description = ''
                File path containing the password to authenticate with.
              '';

              type = lib.types.str;
            };

            port = lib.mkOption {
              description = "TCP port of the SMTP server.";
              type = lib.types.port;
            };

            replyEmail = lib.mkOption {
              description = "Reply address in outgoing mail.";
              type = lib.types.str;
            };

            secure = lib.mkOption {
              default = true;
              description = "Use a secure SMTP connection.";
              type = lib.types.bool;
            };

            tlsCiphers = lib.mkOption {
              default = "";
              description = "Override SMTP cipher configuration.";
              type = lib.types.str;
            };

            username = lib.mkOption {
              description = "Username to authenticate with.";
              type = lib.types.str;
            };
          };
        }
      );
    };

    sslCertFile = lib.mkOption {
      default = null;

      description = ''
        File path that contains the Base64-encoded certificate for HTTPS
        termination. This is only required if you do not use an external reverse
        proxy. See
        [the documentation](https://wiki.generaloutline.com/share/dfa77e56-d4d2-4b51-8ff8-84ea6608faa4).
      '';

      type = lib.types.nullOr lib.types.str;
    };

    #
    # Optional configuration
    #
    sslKeyFile = lib.mkOption {
      default = null;

      description = ''
        File path that contains the Base64-encoded private key for HTTPS
        termination. This is only required if you do not use an external reverse
        proxy. See
        [the documentation](https://wiki.generaloutline.com/share/dfa77e56-d4d2-4b51-8ff8-84ea6608faa4).
      '';

      type = lib.types.nullOr lib.types.str;
    };

    storage = lib.mkOption {
      description = ''
        To support uploading of images for avatars and document attachments an
        s3-compatible storage can be provided. AWS S3 is recommended for
        redundancy however if you want to keep all file storage local an
        alternative such as [garage](https://garagehq.deuxfleurs.fr/)
        can be used.
        Local filesystem storage can also be used.

        A more detailed guide on setting up storage is available
        [here](https://docs.getoutline.com/s/hosting/doc/file-storage-N4M0T6Ypu7).
      '';

      example = lib.literalExpression ''
        {
          accessKey = "...";
          secretKeyFile = "/somewhere";
          uploadBucketUrl = "https://garage.example.com";
          uploadBucketName = "outline";
          region = "us-east-1";
        }
      '';

      type = lib.types.submodule {
        options = {
          accelerateUrl = lib.mkOption {
            default = null;

            description = ''
              URL for AWS S3 [transfer acceleration](https://docs.aws.amazon.com/AmazonS3/latest/userguide/transfer-acceleration.html).
            '';

            type = lib.types.nullOr lib.types.str;
          };

          accessKey = lib.mkOption {
            description = "S3 access key.";
            type = lib.types.str;
          };

          acl = lib.mkOption {
            default = "private";
            description = "ACL setting.";
            type = lib.types.str;
          };

          forcePathStyle = lib.mkOption {
            default = true;
            description = "Force S3 path style.";
            type = lib.types.bool;
          };

          localRootDir = lib.mkOption {
            default = "/var/lib/outline/data";

            description = ''
              If `storageType` is `local`, this sets the parent directory
              under which all attachments/images go.
            '';

            type = lib.types.str;
          };

          region = lib.mkOption {
            default = "xx-xxxx-x";
            description = "AWS S3 region name.";
            type = lib.types.str;
          };

          secretKeyFile = lib.mkOption {
            description = "File path that contains the S3 secret key.";
            type = lib.types.path;
          };

          storageType = lib.mkOption {
            default = "s3";
            description = "File storage type, it can be local or s3.";

            type = lib.types.enum [
              "local"
              "s3"
            ];
          };

          uploadBucketName = lib.mkOption {
            description = "Name of the bucket where uploads should be stored.";
            type = lib.types.str;
          };

          uploadBucketUrl = lib.mkOption {
            description = ''
              URL endpoint of an S3-compatible API where uploads should be
              stored.
            '';

            type = lib.types.str;
          };

          uploadMaxSize = lib.mkOption {
            default = 26214400;
            description = "Maxmium file size for uploads.";
            type = lib.types.int;
          };
        };
      };
    };

    user = lib.mkOption {
      default = defaultUser;

      description = ''
        User under which the service should run. If this is the default value,
        the user will be created, with the specified group as the primary
        group.
      '';

      type = lib.types.str;
    };

    utilsSecretFile = lib.mkOption {
      default = "/var/lib/outline/utils_secret";

      description = ''
        File path that contains the utility secret key. If the file does not
        exist, a new key will be generated and saved here.
      '';

      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = lib.mkIf (cfg.databaseUrl == "local") {
      enable = true;
      ensureDatabases = [ "outline" ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = "outline";
        }
      ];
    };

    services.redis.servers.outline = lib.mkIf (cfg.redisUrl == "local") {
      enable = true;
      port = 0; # Disable the TCP listener
      user = config.services.outline.user;
    };

    systemd.services.outline =
      let
        localRedisUrl = "redis+unix:///run/redis-outline/redis.sock";
        localPostgresqlUrl = "postgres://localhost/outline?host=/run/postgresql";
      in
      {
        after = [
          "network.target"
        ]
        ++ lib.optional (cfg.databaseUrl == "local") "postgresql.target"
        ++ lib.optional (cfg.redisUrl == "local") "redis-outline.service";

        description = "Outline wiki and knowledge base";

        environment = lib.mkMerge [
          {
            CDN_URL = cfg.cdnUrl;
            DEBUG = cfg.debugOutput;
            DEFAULT_LANGUAGE = cfg.defaultLanguage;
            ENABLE_UPDATES = toString cfg.enableUpdateCheck;
            FILE_STORAGE = cfg.storage.storageType;
            FILE_STORAGE_IMPORT_MAX_SIZE = toString cfg.maximumImportSize;
            FILE_STORAGE_LOCAL_ROOT_DIR = cfg.storage.localRootDir;
            FILE_STORAGE_UPLOAD_MAX_SIZE = toString cfg.storage.uploadMaxSize;
            FORCE_HTTPS = toString cfg.forceHttps;
            GOOGLE_ANALYTICS_ID = lib.optionalString (cfg.googleAnalyticsId != null) cfg.googleAnalyticsId;
            NODE_ENV = "production";
            PORT = toString cfg.port;
            RATE_LIMITER_DURATION_WINDOW = toString cfg.rateLimiter.durationWindow;
            RATE_LIMITER_ENABLED = toString cfg.rateLimiter.enable;
            RATE_LIMITER_REQUESTS = toString cfg.rateLimiter.requests;
            REDIS_URL = if cfg.redisUrl == "local" then localRedisUrl else cfg.redisUrl;
            SENTRY_DSN = lib.optionalString (cfg.sentryDsn != null) cfg.sentryDsn;
            SENTRY_TUNNEL = lib.optionalString (cfg.sentryTunnel != null) cfg.sentryTunnel;
            TEAM_LOGO = lib.optionalString (cfg.logo != null) cfg.logo;
            URL = cfg.publicUrl;
            WEB_CONCURRENCY = toString cfg.concurrency;
          }

          (lib.mkIf (cfg.storage.storageType == "s3") {
            AWS_ACCESS_KEY_ID = cfg.storage.accessKey;
            AWS_REGION = cfg.storage.region;
            AWS_S3_ACL = cfg.storage.acl;
            AWS_S3_FORCE_PATH_STYLE = toString cfg.storage.forcePathStyle;
            AWS_S3_UPLOAD_BUCKET_NAME = cfg.storage.uploadBucketName;
            AWS_S3_UPLOAD_BUCKET_URL = cfg.storage.uploadBucketUrl;
          })

          (lib.mkIf (cfg.storage.storageType == "s3" && cfg.storage.accelerateUrl != null) {
            AWS_S3_ACCELERATE_URL = cfg.storage.accelerateUrl;
          })

          (lib.mkIf (cfg.slackAuthentication != null) {
            SLACK_CLIENT_ID = cfg.slackAuthentication.clientId;
          })

          (lib.mkIf (cfg.googleAuthentication != null) {
            GOOGLE_CLIENT_ID = cfg.googleAuthentication.clientId;
          })

          (lib.mkIf (cfg.azureAuthentication != null) {
            AZURE_CLIENT_ID = cfg.azureAuthentication.clientId;
            AZURE_RESOURCE_APP_ID = cfg.azureAuthentication.resourceAppId;
          })

          (lib.mkIf (cfg.oidcAuthentication != null) {
            OIDC_AUTH_URI = cfg.oidcAuthentication.authUrl;
            OIDC_CLIENT_ID = cfg.oidcAuthentication.clientId;
            OIDC_DISPLAY_NAME = cfg.oidcAuthentication.displayName;
            OIDC_SCOPES = lib.concatStringsSep " " cfg.oidcAuthentication.scopes;
            OIDC_TOKEN_URI = cfg.oidcAuthentication.tokenUrl;
            OIDC_USERINFO_URI = cfg.oidcAuthentication.userinfoUrl;
            OIDC_USERNAME_CLAIM = cfg.oidcAuthentication.usernameClaim;
          })

          (lib.mkIf (cfg.slackIntegration != null) {
            SLACK_APP_ID = cfg.slackIntegration.appId;
            SLACK_MESSAGE_ACTIONS = toString cfg.slackIntegration.messageActions;
          })

          (lib.mkIf (cfg.discordAuthentication != null) {
            DISCORD_CLIENT_ID = cfg.discordAuthentication.clientId;
            DISCORD_SERVER_ID = cfg.discordAuthentication.serverId;
            DISCORD_SERVER_ROLES = cfg.discordAuthentication.serverRoles;
          })

          (lib.mkIf (cfg.smtp != null) {
            SMTP_FROM_EMAIL = cfg.smtp.fromEmail;
            SMTP_HOST = cfg.smtp.host;
            SMTP_PORT = toString cfg.smtp.port;
            SMTP_REPLY_EMAIL = cfg.smtp.replyEmail;
            SMTP_SECURE = toString cfg.smtp.secure;
            SMTP_TLS_CIPHERS = cfg.smtp.tlsCiphers;
            SMTP_USERNAME = cfg.smtp.username;
          })
        ];

        path = [
          pkgs.openssl # Required by the preStart script
        ];

        preStart = ''
          if [ ! -s ${lib.escapeShellArg cfg.secretKeyFile} ]; then
            openssl rand -hex 32 > ${lib.escapeShellArg cfg.secretKeyFile}
          fi
          if [ ! -s ${lib.escapeShellArg cfg.utilsSecretFile} ]; then
            openssl rand -hex 32 > ${lib.escapeShellArg cfg.utilsSecretFile}
          fi

        '';

        requires =
          lib.optional (cfg.databaseUrl == "local") "postgresql.target"
          ++ lib.optional (cfg.redisUrl == "local") "redis-outline.service";

        script = ''
          SECRET_KEY="$(head -n1 ${lib.escapeShellArg cfg.secretKeyFile})"
          export SECRET_KEY
          UTILS_SECRET="$(head -n1 ${lib.escapeShellArg cfg.utilsSecretFile})"
          export UTILS_SECRET
          ${lib.optionalString (cfg.storage.storageType == "s3") ''
            AWS_SECRET_ACCESS_KEY="$(head -n1 ${lib.escapeShellArg cfg.storage.secretKeyFile})"
            export AWS_SECRET_ACCESS_KEY
          ''}
          ${lib.optionalString (cfg.slackAuthentication != null) ''
            SLACK_CLIENT_SECRET="$(head -n1 ${lib.escapeShellArg cfg.slackAuthentication.secretFile})"
            export SLACK_CLIENT_SECRET
          ''}
          ${lib.optionalString (cfg.googleAuthentication != null) ''
            GOOGLE_CLIENT_SECRET="$(head -n1 ${lib.escapeShellArg cfg.googleAuthentication.clientSecretFile})"
            export GOOGLE_CLIENT_SECRET
          ''}
          ${lib.optionalString (cfg.azureAuthentication != null) ''
            AZURE_CLIENT_SECRET="$(head -n1 ${lib.escapeShellArg cfg.azureAuthentication.clientSecretFile})"
            export AZURE_CLIENT_SECRET
          ''}
          ${lib.optionalString (cfg.oidcAuthentication != null) ''
            OIDC_CLIENT_SECRET="$(head -n1 ${lib.escapeShellArg cfg.oidcAuthentication.clientSecretFile})"
            export OIDC_CLIENT_SECRET
          ''}
          ${lib.optionalString (cfg.discordAuthentication != null) ''
            DISCORD_CLIENT_SECRET="$(head -n1 ${lib.escapeShellArg cfg.discordAuthentication.clientSecretFile})"
            export DISCORD_CLIENT_SECRET
          ''}
          ${lib.optionalString (cfg.sslKeyFile != null) ''
            SSL_KEY="$(head -n1 ${lib.escapeShellArg cfg.sslKeyFile})"
            export SSL_KEY
          ''}
          ${lib.optionalString (cfg.sslCertFile != null) ''
            SSL_CERT="$(head -n1 ${lib.escapeShellArg cfg.sslCertFile})"
            export SSL_CERT
          ''}
          ${lib.optionalString (cfg.slackIntegration != null) ''
            SLACK_VERIFICATION_TOKEN="$(head -n1 ${lib.escapeShellArg cfg.slackIntegration.verificationTokenFile})"
            export SLACK_VERIFICATION_TOKEN
          ''}
          ${lib.optionalString (cfg.smtp != null) ''
            SMTP_PASSWORD="$(head -n1 ${lib.escapeShellArg cfg.smtp.passwordFile})"
            export SMTP_PASSWORD
          ''}

          ${
            if (cfg.databaseUrl == "local") then
              ''
                if [ -z "''${DATABASE_URL:-}" ]; then
                  DATABASE_URL=${lib.escapeShellArg localPostgresqlUrl}
                fi
                export DATABASE_URL
                export PGSSLMODE="''${PGSSLMODE:-disable}"
              ''
            else
              ''
                if [ -z "''${DATABASE_URL:-}" ]; then
                  DATABASE_URL=${lib.escapeShellArg cfg.databaseUrl}
                fi
                export DATABASE_URL
              ''
          }

          ${cfg.package}/bin/outline-server
        '';

        serviceConfig = {
          Group = cfg.group;
          PrivateTmp = true;
          ProtectSystem = "strict";
          # In case this directory is not in /var/lib/outline, it needs to be made writable explicitly
          ReadWritePaths = lib.mkIf (cfg.storage.storageType == "local") [ cfg.storage.localRootDir ];
          Restart = "always";
          RuntimeDirectory = "outline";
          RuntimeDirectoryMode = "0750";
          StateDirectory = "outline";
          StateDirectoryMode = "0750";
          UMask = "0007";
          User = cfg.user;
          # This working directory is required to find stuff like the set of
          # onboarding files:
          WorkingDirectory = "${cfg.package}/share/outline";
        };

        wantedBy = [ "multi-user.target" ];
      };

    systemd.tmpfiles.rules = [
      "f ${cfg.secretKeyFile} 0600 ${cfg.user} ${cfg.group} -"
      "f ${cfg.utilsSecretFile} 0600 ${cfg.user} ${cfg.group} -"
      (
        if (cfg.storage.storageType == "s3") then
          "f ${cfg.storage.secretKeyFile} 0600 ${cfg.user} ${cfg.group} -"
        else
          "d ${cfg.storage.localRootDir} 0700 ${cfg.user} ${cfg.group} - -"
      )
    ];

    users.groups = lib.optionalAttrs (cfg.group == defaultUser) {
      ${defaultUser} = { };
    };

    users.users = lib.optionalAttrs (cfg.user == defaultUser) {
      ${defaultUser} = {
        group = cfg.group;
        isSystemUser = true;
      };
    };
  };
}
