{
  config,
  lib,
  pkgs,
  options,
  utils,
  ...
}:

let
  json = pkgs.formats.json { };

  cfg = config.services.discourse;
  opt = options.services.discourse;

  # Keep in sync with https://github.com/discourse/discourse_docker/blob/main/image/base/Dockerfile PG_MAJOR
  upstreamPostgresqlVersion = lib.getVersion pkgs.postgresql_15;

  postgresqlPackage =
    if config.services.postgresql.enable then
      config.services.postgresql.finalPackage
    else
      pkgs.postgresql;

  postgresqlVersion = lib.getVersion postgresqlPackage;

  # We only want to create a database if we're actually going to connect to it.
  databaseActuallyCreateLocally = cfg.database.createLocally && cfg.database.host == null;

  tlsEnabled = cfg.enableACME || cfg.sslCertificate != null || cfg.sslCertificateKey != null;
in
{
  options = {
    services.discourse = {
      enable = lib.mkEnableOption "Discourse, an open source discussion platform";

      package = lib.mkOption {
        apply =
          p:
          p.override {
            plugins = lib.unique (p.enabledPlugins ++ cfg.plugins);
          };

        default = pkgs.discourse;
        defaultText = lib.literalExpression "pkgs.discourse";

        description = ''
          The discourse package to use.
        '';

        type = lib.types.package;
      };

      admin = {
        email = lib.mkOption {
          description = ''
            The admin user email address.
          '';

          example = "admin@example.com";
          type = lib.types.str;
        };

        fullName = lib.mkOption {
          description = ''
            The admin user's full name.
          '';

          type = lib.types.str;
        };

        passwordFile = lib.mkOption {
          description = ''
            A path to a file containing the admin user's password.

            This should be a string, not a nix path, since nix paths are
            copied into the world-readable nix store.
          '';

          type = lib.types.path;
        };

        skipCreate = lib.mkOption {
          default = false;

          description = ''
            Do not create the admin account, instead rely on other
            existing admin accounts.
          '';

          type = lib.types.bool;
        };

        username = lib.mkOption {
          description = ''
            The admin user username.
          '';

          example = "admin";
          type = lib.types.str;
        };
      };

      backendSettings = lib.mkOption {
        default = { };

        description = ''
          Additional settings to put in the
          {file}`discourse.conf` file.

          Look in the
          [discourse_defaults.conf](https://github.com/discourse/discourse/blob/master/config/discourse_defaults.conf)
          file in the upstream distribution to find available options.

          Setting an option to `null` means
          “define variable, but leave right-hand side empty”.
        '';

        example = lib.literalExpression ''
          {
            max_reqs_per_ip_per_minute = 300;
            max_reqs_per_ip_per_10_seconds = 60;
            max_asset_reqs_per_ip_per_10_seconds = 250;
            max_reqs_per_ip_mode = "warn+block";
          };
        '';

        type =
          with lib.types;
          attrsOf (
            nullOr (oneOf [
              str
              int
              bool
              float
            ])
          );
      };

      database = {
        createLocally = lib.mkOption {
          default = true;

          description = ''
            Whether a database should be automatically created on the
            local host. Set this to `false` if you plan
            on provisioning a local database yourself. This has no effect
            if {option}`services.discourse.database.host` is customized.
          '';

          type = lib.types.bool;
        };

        host = lib.mkOption {
          default = null;

          description = ''
            Discourse database hostname. `null` means
            “prefer local unix socket connection”.
          '';

          type = with lib.types; nullOr str;
        };

        ignorePostgresqlVersion = lib.mkOption {
          default = false;

          description = ''
            Whether to allow other versions of PostgreSQL than the
            recommended one. Only effective when
            {option}`services.discourse.database.createLocally`
            is enabled.
          '';

          type = lib.types.bool;
        };

        name = lib.mkOption {
          default = "discourse";

          description = ''
            Discourse database name.
          '';

          type = lib.types.str;
        };

        passwordFile = lib.mkOption {
          default = null;

          description = ''
            File containing the Discourse database user password.

            This should be a string, not a nix path, since nix paths are
            copied into the world-readable nix store.
          '';

          type = with lib.types; nullOr path;
        };

        pool = lib.mkOption {
          default = 8;

          description = ''
            Database connection pool size.
          '';

          type = lib.types.int;
        };

        username = lib.mkOption {
          default = "discourse";

          description = ''
            Discourse database user.
          '';

          type = lib.types.str;
        };
      };

      enableACME = lib.mkOption {
        default = cfg.sslCertificate == null && cfg.sslCertificateKey == null;

        defaultText = lib.literalMD ''
          `true`, unless {option}`services.discourse.sslCertificate`
          and {option}`services.discourse.sslCertificateKey` are set.
        '';

        description = ''
          Whether an ACME certificate should be used to secure
          connections to the server.
        '';

        type = lib.types.bool;
      };

      hostname = lib.mkOption {
        default = config.networking.fqdnOrHostName;
        defaultText = lib.literalExpression "config.networking.fqdnOrHostName";

        description = ''
          The hostname to serve Discourse on.
        '';

        example = "discourse.example.com";
        type = lib.types.str;
      };

      mail = {
        contactEmailAddress = lib.mkOption {
          default = "";

          description = ''
            Email address of key contact responsible for this
            site. Used for critical notifications, as well as on the
            `/about` contact form for urgent matters.
          '';

          type = lib.types.str;
        };

        incoming = {
          enable = lib.mkOption {
            default = false;

            description = ''
              Whether to set up Postfix to receive incoming mail.
            '';

            type = lib.types.bool;
          };

          apiKeyFile = lib.mkOption {
            default = null;

            description = ''
              A file containing the Discourse API key used to add
              posts and messages from mail. If left at its default
              value `null`, one will be automatically
              generated.

              This should be a string, not a nix path, since nix paths
              are copied into the world-readable nix store.
            '';

            type = lib.types.nullOr lib.types.path;
          };

          mailReceiverPackage = lib.mkOption {
            default = pkgs.discourse-mail-receiver;
            defaultText = lib.literalExpression "pkgs.discourse-mail-receiver";

            description = ''
              The discourse-mail-receiver package to use.
            '';

            type = lib.types.package;
          };

          replyEmailAddress = lib.mkOption {
            default = "%{reply_key}@${cfg.hostname}";
            defaultText = lib.literalExpression ''"%{reply_key}@''${config.services.discourse.hostname}"'';

            description = ''
              Template for reply by email incoming email address, for
              example: %{reply_key}@reply.example.com or
              replies+%{reply_key}@example.com
            '';

            type = lib.types.str;
          };
        };

        notificationEmailAddress = lib.mkOption {
          default = "${if cfg.mail.incoming.enable then "notifications" else "noreply"}@${cfg.hostname}";

          defaultText = lib.literalExpression ''
            "''${if config.services.discourse.mail.incoming.enable then "notifications" else "noreply"}@''${config.services.discourse.hostname}"
          '';

          description = ''
            The `from:` email address used when
            sending all essential system emails. The domain specified
            here must have SPF, DKIM and reverse PTR records set
            correctly for email to arrive.
          '';

          type = lib.types.str;
        };

        outgoing = {
          authentication = lib.mkOption {
            default = null;

            description = ''
              Authentication type to use, see <https://api.rubyonrails.org/classes/ActionMailer/Base.html>
            '';

            type =
              with lib.types;
              nullOr (enum [
                "plain"
                "login"
                "cram_md5"
              ]);
          };

          domain = lib.mkOption {
            default = cfg.hostname;
            defaultText = lib.literalExpression "config.${opt.hostname}";

            description = ''
              HELO domain to use for outgoing mail.
            '';

            type = lib.types.str;
          };

          enableStartTLSAuto = lib.mkOption {
            default = true;

            description = ''
              Whether to try to use StartTLS.
            '';

            type = lib.types.bool;
          };

          forceTLS = lib.mkOption {
            default = false;

            description = ''
              Force implicit TLS as per RFC 8314 3.3.
            '';

            type = lib.types.bool;
          };

          opensslVerifyMode = lib.mkOption {
            default = "peer";

            description = ''
              How OpenSSL checks the certificate, see <https://api.rubyonrails.org/classes/ActionMailer/Base.html>
            '';

            type = lib.types.str;
          };

          passwordFile = lib.mkOption {
            default = null;

            description = ''
              A file containing the password of the SMTP server account.

              This should be a string, not a nix path, since nix paths
              are copied into the world-readable nix store.
            '';

            type = lib.types.nullOr lib.types.path;
          };

          port = lib.mkOption {
            default = 25;

            description = ''
              The port of the SMTP server Discourse should use to
              send email.
            '';

            type = lib.types.port;
          };

          serverAddress = lib.mkOption {
            default = "localhost";

            description = ''
              The address of the SMTP server Discourse should use to
              send email.
            '';

            type = lib.types.str;
          };

          username = lib.mkOption {
            default = null;

            description = ''
              The username of the SMTP server.
            '';

            type = with lib.types; nullOr str;
          };
        };
      };

      nginx.enable = lib.mkOption {
        default = true;

        description = ''
          Whether an `nginx` virtual host should be
          set up to serve Discourse. Only disable if you're planning
          to use a different web server, which is not recommended.
        '';

        type = lib.types.bool;
      };

      plugins = lib.mkOption {
        default = [ ];

        description = ''
          Plugins to install as part of Discourse, expressed as a list of derivations.
        '';

        example = lib.literalExpression ''
          with config.services.discourse.package.plugins; [
            discourse-canned-replies
            discourse-github
          ];
        '';

        type = lib.types.listOf lib.types.package;
      };

      redis = {
        dbNumber = lib.mkOption {
          default = 0;

          description = ''
            Redis database number.
          '';

          type = lib.types.int;
        };

        host = lib.mkOption {
          default = "localhost";

          description = ''
            Redis server hostname.
          '';

          type = lib.types.str;
        };

        passwordFile = lib.mkOption {
          default = null;

          description = ''
            File containing the Redis password.

            This should be a string, not a nix path, since nix paths are
            copied into the world-readable nix store.
          '';

          type = with lib.types; nullOr path;
        };

        useSSL = lib.mkOption {
          default = cfg.redis.host != "localhost";
          defaultText = lib.literalExpression ''config.${opt.redis.host} != "localhost"'';

          description = ''
            Connect to Redis with SSL.
          '';

          type = lib.types.bool;
        };
      };

      secretKeyBaseFile = lib.mkOption {
        default = null;

        description = ''
          The path to a file containing the
          `secret_key_base` secret.

          Discourse uses `secret_key_base` to encrypt
          the cookie store, which contains session data, and to digest
          user auth tokens.

          Needs to be a 64 byte long string of hexadecimal
          characters. You can generate one by running

          ```
          openssl rand -hex 64 >/path/to/secret_key_base_file
          ```

          This should be a string, not a nix path, since nix paths are
          copied into the world-readable nix store.
        '';

        example = "/run/keys/secret_key_base";
        type = with lib.types; nullOr path;
      };

      sidekiqProcesses = lib.mkOption {
        default = 1;

        description = ''
          How many Sidekiq processes should be spawned.
        '';

        type = lib.types.int;
      };

      siteSettings = lib.mkOption {
        default = { };

        description = ''
          Discourse site settings. These are the settings that can be
          changed from the UI. This only defines their default values:
          they can still be overridden from the UI.

          Available settings can be found by looking in the
          [site_settings.yml](https://github.com/discourse/discourse/blob/master/config/site_settings.yml)
          file of the upstream distribution. To find a setting's path,
          you only need to care about the first two levels; i.e. its
          category and name. See the example.

          Settings containing secret data should be set to an
          attribute set containing the attribute
          `_secret` - a string pointing to a file
          containing the value the option should be set to. See the
          example to get a better picture of this: in the resulting
          {file}`config/nixos_site_settings.json` file,
          the `login.github_client_secret` key will
          be set to the contents of the
          {file}`/run/keys/discourse_github_client_secret`
          file.
        '';

        example = lib.literalExpression ''
          {
            required = {
              title = "My Cats";
              site_description = "Discuss My Cats (and be nice plz)";
            };
            login = {
              enable_github_logins = true;
              github_client_id = "a2f6dfe838cb3206ce20";
              github_client_secret._secret = /run/keys/discourse_github_client_secret;
            };
          };
        '';

        type = json.type;
      };

      sslCertificate = lib.mkOption {
        default = null;

        description = ''
          The path to the server SSL certificate. Set this to enable
          SSL.
        '';

        example = "/run/keys/ssl.cert";
        type = with lib.types; nullOr path;
      };

      sslCertificateKey = lib.mkOption {
        default = null;

        description = ''
          The path to the server SSL certificate key. Set this to
          enable SSL.
        '';

        example = "/run/keys/ssl.key";
        type = with lib.types; nullOr path;
      };

      unicornTimeout = lib.mkOption {
        default = 30;

        description = ''
          Time in seconds before a request to Unicorn times out.

          This can be raised if the system Discourse is running on is
          too slow to handle many requests within 30 seconds.
        '';

        type = lib.types.int;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.database.host != null) -> (cfg.database.passwordFile != null);
        message = "When services.discourse.database.host is customized, services.discourse.database.passwordFile must be set!";
      }
      {
        assertion = cfg.hostname != "";
        message = "Could not automatically determine hostname, set service.discourse.hostname manually.";
      }
      {
        assertion =
          cfg.database.ignorePostgresqlVersion
          || (databaseActuallyCreateLocally -> upstreamPostgresqlVersion == postgresqlVersion);

        message =
          "The PostgreSQL version recommended for use with Discourse is ${upstreamPostgresqlVersion}, you're using ${postgresqlVersion}. "
          + "Either update your PostgreSQL package to the correct version or set services.discourse.database.ignorePostgresqlVersion. "
          + "See https://nixos.org/manual/nixos/stable/index.html#module-postgresql for details on how to upgrade PostgreSQL.";
      }
    ];

    environment.systemPackages = [
      cfg.package.rake
    ];

    # Default config values are from `config/discourse_defaults.conf`
    # upstream.
    services.discourse.backendSettings = lib.mapAttrs (_: lib.mkDefault) {
      inherit (cfg) hostname;
      allow_impersonation = true;
      allowed_theme_repos = null;
      anon_cache_store_threshold = 2;
      background_requests_max_queue_length = 0.5;
      backup_hostname = null;
      cdn_origin_hostname = null;
      cdn_url = null;
      cluster_name = null;
      compress_anon_cache = false;
      connection_reaper_age = 30;
      connection_reaper_interval = 30;
      cors_origin = "";
      db_advisory_locks = true;
      db_backup_host = null;
      db_backup_port = 5432;
      db_connect_timeout = 5;
      db_host = cfg.database.host;
      db_name = cfg.database.name;
      db_password = cfg.database.passwordFile;
      db_pool = cfg.database.pool;
      db_port = null;
      db_prepared_statements = false;
      db_replica_host = null;
      db_replica_port = null;
      db_socket = null;
      db_timeout = 5000;
      db_username = if databaseActuallyCreateLocally then "discourse" else cfg.database.username;
      developer_emails = null;
      disable_search_queue_threshold = 1;
      dns_query_timeout_secs = null;
      enable_cors = false;
      enable_email_sync_demon = false;
      enable_js_error_reporting = true;
      enable_long_polling = null;
      enable_performance_http_headers = false;
      fallback_assets_path = null;
      force_anonymous_min_per_10_seconds = 3;
      force_anonymous_min_queue_seconds = 1;
      load_mini_profiler = true;
      log_line_max_chars = 160000;
      long_polling_interval = null;
      max_admin_api_reqs_per_minute = 60;
      max_asset_reqs_per_ip_per_10_seconds = 200;
      max_digests_enqueued_per_30_mins_per_site = 10000;
      max_logster_logs = 1000;
      max_old_rebakes_per_15_minutes = 300;
      max_reqs_per_ip_mode = "block";
      max_reqs_per_ip_per_10_seconds = 50;
      max_reqs_per_ip_per_minute = 200;
      max_reqs_rate_limit_on_private = false;
      max_user_api_reqs_per_day = 2880;
      max_user_api_reqs_per_minute = 20;
      maxmind_backup_path = null;
      maxmind_license_key = null;
      message_bus_clear_every = 50;
      message_bus_max_backlog_size = 100;
      message_bus_redis_db = 0;
      message_bus_redis_enabled = false;
      message_bus_redis_host = "localhost";
      message_bus_redis_password = null;
      message_bus_redis_port = 6379;
      message_bus_redis_replica_host = null;
      message_bus_redis_replica_port = 6379;
      message_bus_redis_skip_client_commands = false;
      mini_profiler_snapshots_period = 0;
      mini_profiler_snapshots_transport_auth_key = null;
      mini_profiler_snapshots_transport_url = null;
      mini_scheduler_workers = 5;
      multisite_config_path = "config/multisite.yml";
      pg_force_readonly_mode = false;
      preload_link_header = false;
      redirect_avatar_requests = false;
      redis_db = cfg.redis.dbNumber;
      redis_host = cfg.redis.host;
      redis_password = cfg.redis.passwordFile;
      redis_port = 6379;
      redis_replica_host = null;
      redis_replica_port = 6379;
      redis_skip_client_commands = false;
      redis_use_ssl = cfg.redis.useSSL;
      refresh_maxmind_db_during_precompile_days = 2;
      regex_timeout_seconds = 2;
      reject_message_bus_queue_seconds = 0.1;
      relative_url_root = null;
      s3_access_key_id = null;
      s3_asset_cdn_url = null;
      s3_bucket = null;
      s3_cdn_url = null;
      s3_endpoint = null;
      s3_http_continue_timeout = null;
      s3_install_cors_rule = null;
      s3_region = null;
      s3_secret_access_key = null;
      s3_use_iam_profile = null;
      secret_key_base = cfg.secretKeyBaseFile;
      serve_static_assets = false;
      sidekiq_workers = 5;
      skip_per_ip_rate_limit_trust_level = 1;
      smtp_address = cfg.mail.outgoing.serverAddress;
      smtp_authentication = cfg.mail.outgoing.authentication;
      smtp_domain = cfg.mail.outgoing.domain;
      smtp_enable_start_tls = cfg.mail.outgoing.enableStartTLSAuto;
      smtp_force_tls = cfg.mail.outgoing.forceTLS;
      smtp_openssl_verify_mode = cfg.mail.outgoing.opensslVerifyMode;
      smtp_password = cfg.mail.outgoing.passwordFile;
      smtp_port = cfg.mail.outgoing.port;
      smtp_user_name = cfg.mail.outgoing.username;
      yjit_enabled = false;
    };

    services.discourse.siteSettings = {
      email = {
        manual_polling_enabled = cfg.mail.incoming.enable;
        reply_by_email_address = cfg.mail.incoming.replyEmailAddress;
        reply_by_email_enabled = cfg.mail.incoming.enable;
      };

      required = {
        contact_email = cfg.mail.contactEmailAddress;
        notification_email = cfg.mail.notificationEmailAddress;
      };

      security.force_https = tlsEnabled;
    };

    services.nginx = lib.mkIf cfg.nginx.enable {
      enable = true;

      appendHttpConfig = ''
        # inactive means we keep stuff around for 1440m minutes regardless of last access (1 week)
        # levels means it is a 2 deep hierarchy cause we can have lots of files
        # max_size limits the size of the cache
        proxy_cache_path /var/cache/nginx inactive=1440m levels=1:2 keys_zone=discourse:10m max_size=600m;

        # see: https://meta.discourse.org/t/x/74060
        proxy_buffer_size 8k;
      '';

      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      upstreams.discourse.servers."unix:/run/discourse/sockets/unicorn.sock" = { };

      virtualHosts.${cfg.hostname} = {
        inherit (cfg) sslCertificate sslCertificateKey enableACME;
        forceSSL = lib.mkDefault tlsEnabled;

        locations =
          let
            proxy =
              {
                extraConfig ? "",
              }:
              {
                extraConfig = extraConfig + ''
                  proxy_set_header X-Request-Start "t=''${msec}";
                  proxy_set_header X-Sendfile-Type "";
                  proxy_set_header X-Accel-Mapping "";
                  proxy_set_header Client-Ip "";
                '';

                proxyPass = "http://discourse";
              };
            cache = time: ''
              expires ${time};
              add_header Cache-Control public,immutable;
            '';
            cache_1y = cache "1y";
            cache_1d = cache "1d";
          in
          {
            "/".tryFiles = "$uri @discourse";

            "/downloads/".extraConfig = ''
              internal;
              alias ${cfg.package}/share/discourse/public/;
            '';

            "/favicon.ico" = {
              extraConfig = ''
                access_log off;
                log_not_found off;
              '';

              return = "204";
            };

            "/message-bus/" = proxy {
              extraConfig = ''
                proxy_http_version 1.1;
                proxy_buffering off;
              '';
            };

            "/srv/status" = proxy {
              extraConfig = ''
                access_log off;
                log_not_found off;
              '';
            };

            "@discourse" = proxy { };

            "^~ /backups/".extraConfig = ''
              internal;
            '';

            "~ /images/emoji/".extraConfig = cache_1y;

            "~ ^/(svg-sprite/|letter_avatar/|letter_avatar_proxy/|user_avatar|highlight-js|stylesheets|theme-javascripts|favicon/proxied|service-worker)" =
              proxy {
                extraConfig = ''
                  # if Set-Cookie is in the response nothing gets cached
                  # this is double bad cause we are not passing last modified in
                  proxy_ignore_headers "Set-Cookie";
                  proxy_hide_header "Set-Cookie";
                  proxy_hide_header "X-Discourse-Username";
                  proxy_hide_header "X-Runtime";

                  # note x-accel-redirect can not be used with proxy_cache
                  proxy_cache discourse;
                  proxy_cache_key "$scheme,$host,$request_uri";
                  proxy_cache_valid 200 301 302 7d;
                '';
              };

            "~ ^/admin/backups/" = proxy {
              extraConfig = ''
                proxy_set_header X-Sendfile-Type X-Accel-Redirect;
                proxy_set_header X-Accel-Mapping ${cfg.package}/share/discourse/public/=/downloads/;
              '';
            };

            "~ ^/assets/(?<asset_path>.+)$".extraConfig = cache_1y + ''
              # asset pipeline enables this
              brotli_static on;
              gzip_static on;
            '';

            "~ ^/javascripts/".extraConfig = cache_1d;
            "~ ^/plugins/".extraConfig = cache_1y;
            "~ ^/secure-media-uploads/" = proxy { };

            "~ ^/uploads/" = proxy {
              extraConfig = cache_1y + ''
                proxy_set_header X-Sendfile-Type X-Accel-Redirect;
                proxy_set_header X-Accel-Mapping ${cfg.package}/share/discourse/public/=/downloads/;

                # custom CSS
                location ~ /stylesheet-cache/ {
                    try_files $uri =404;
                }
                # this allows us to bypass rails
                location ~* \.(gif|png|jpg|jpeg|bmp|tif|tiff|ico|webp)$ {
                    try_files $uri =404;
                }
                # SVG needs an extra header attached
                location ~* \.(svg)$ {
                }
                # thumbnails & optimized images
                location ~ /_?optimized/ {
                    try_files $uri =404;
                }
              '';
            };

            "~ ^/uploads/short-url/" = proxy { };

            "~* (fonts|assets|plugins|uploads)/.*\\.(eot|ttf|woff|woff2|ico|otf)$".extraConfig = cache_1y + ''
              add_header Access-Control-Allow-Origin *;
            '';
          };

        root = "${cfg.package}/share/discourse/public";
      };
    };

    services.postfix = lib.mkIf cfg.mail.incoming.enable {
      enable = true;

      settings.main = {
        append_dot_mydomain = lib.mkDefault false;
        compatibility_level = "2";
        mydestination = lib.mkDefault "localhost";
        myhostname = lib.mkDefault cfg.hostname;
        myorigin = cfg.hostname;
        relay_domains = [ cfg.hostname ];
        smtpd_banner = lib.mkDefault "ESMTP server";
        smtpd_recipient_restrictions = "check_policy_service unix:private/discourse-policy";

        smtpd_tls_chain_files =
          lib.optionals (cfg.sslCertificate != null && cfg.sslCertificateKey != null)
            [
              cfg.sslCertificateKey
              cfg.sslCertificate
            ];

        smtputf8_enable = false;
      };

      settings.master = {
        "discourse-mail-receiver" = {
          args = [
            "user=discourse"
            "argv=${cfg.mail.incoming.mailReceiverPackage}/bin/receive-mail"
            "\${recipient}"
          ];

          chroot = false;
          command = "pipe";
          privileged = true;
          type = "unix";
        };

        "discourse-policy" = {
          args = [
            "user=discourse"
            "argv=${cfg.mail.incoming.mailReceiverPackage}/bin/discourse-smtp-fast-rejection"
          ];

          chroot = false;
          command = "spawn";
          privileged = true;
          type = "unix";
        };
      };

      transport = ''
        ${cfg.hostname} discourse-mail-receiver:
      '';
    };

    services.postgresql = lib.mkIf databaseActuallyCreateLocally {
      enable = true;
      ensureUsers = [ { name = "discourse"; } ];

      extensions = ps: [
        ps.pgvector
      ];
    };

    services.redis.servers.discourse =
      lib.mkIf
        (lib.elem cfg.redis.host [
          "localhost"
          "127.0.0.1"
        ])
        {
          enable = true;
          bind = cfg.redis.host;
          port = cfg.backendSettings.redis_port;
        };

    systemd.services.discourse = {
      after = [
        "redis-discourse.service"
        "postgresql.target"
        "discourse-postgresql.service"
      ];

      bindsTo = [
        "redis-discourse.service"
      ]
      ++ lib.optionals (cfg.database.host == null) [
        "postgresql.target"
        "discourse-postgresql.service"
      ];

      environment = cfg.package.runtimeEnv // {
        MALLOC_ARENA_MAX = "2";
        UNICORN_SIDEKIQS = toString cfg.sidekiqProcesses;
        UNICORN_TIMEOUT = toString cfg.unicornTimeout;
      };

      path = cfg.package.runtimeDeps ++ [
        postgresqlPackage
        pkgs.replace-secret
        cfg.package.rake
      ];

      preStart =
        let
          discourseKeyValue = lib.generators.toKeyValue {
            mkKeyValue = lib.flip lib.generators.mkKeyValueDefault " = " {
              mkValueString =
                v:
                with builtins;
                if isInt v then
                  toString v
                else if isString v then
                  ''"${v}"''
                else if true == v then
                  "true"
                else if false == v then
                  "false"
                else if null == v then
                  ""
                else if isFloat v then
                  lib.strings.floatToString v
                else
                  throw "unsupported type ${typeOf v}: ${(lib.generators.toPretty { }) v}";
            };
          };

          discourseConf = pkgs.writeText "discourse.conf" (discourseKeyValue cfg.backendSettings);

          mkSecretReplacement =
            file:
            lib.optionalString (file != null) ''
              replace-secret '${file}' '${file}' /run/discourse/config/discourse.conf
            '';

          mkAdmin = ''
            export ADMIN_EMAIL="${cfg.admin.email}"
            export ADMIN_NAME="${cfg.admin.fullName}"
            export ADMIN_USERNAME="${cfg.admin.username}"
            ADMIN_PASSWORD="$(<${cfg.admin.passwordFile})"
            export ADMIN_PASSWORD
            discourse-rake admin:create_noninteractively
          '';

        in
        ''
          set -o errexit -o pipefail -o nounset -o errtrace
          shopt -s inherit_errexit

          umask u=rwx,g=rx,o=

          rm -rf /var/lib/discourse/tmp/*

          cp -r ${cfg.package}/share/discourse/config.dist/* /run/discourse/config/
          cp -r ${cfg.package}/share/discourse/public.dist/* /run/discourse/public/
          cp -r ${cfg.package.assets.generated}/* /run/discourse/assets-generated/
          ln -sf /var/lib/discourse/uploads /run/discourse/public/uploads
          ln -sf /var/lib/discourse/backups /run/discourse/public/backups
          # discourse creates images in this folder, and by default it only has u=rx
          chmod 750 /run/discourse/public/images

          (
              umask u=rwx,g=,o=

              ${utils.genJqSecretsReplacementSnippet cfg.siteSettings "/run/discourse/config/nixos_site_settings.json"}
              install -T -m 0600 -o discourse ${discourseConf} /run/discourse/config/discourse.conf
              ${mkSecretReplacement cfg.database.passwordFile}
              ${mkSecretReplacement cfg.mail.outgoing.passwordFile}
              ${mkSecretReplacement cfg.redis.passwordFile}
              ${mkSecretReplacement cfg.secretKeyBaseFile}
              chmod 0400 /run/discourse/config/discourse.conf
          )

          discourse-rake db:migrate >>/var/log/discourse/db_migration.log
          chmod -R u+w /var/lib/discourse/tmp/

          ${lib.optionalString (!cfg.admin.skipCreate) mkAdmin}

          discourse-rake themes:update
          discourse-rake uploads:regenerate_missing_optimized
        '';

      serviceConfig = {
        ExecStart = "${cfg.package.rubyEnv}/bin/bundle exec config/unicorn_launcher -E production -c config/unicorn.conf.rb";
        Group = "discourse";
        LogsDirectory = "discourse";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = "read-only";
        ProtectSystem = "strict";
        RemoveIPC = true;
        Restart = "on-failure";
        RestrictSUIDSGID = true;

        RuntimeDirectory = map (p: "discourse/" + p) [
          "config"
          "home"
          "public"
          "sockets"
          "assets-generated"
        ];

        RuntimeDirectoryMode = "0750";

        StateDirectory = map (p: "discourse/" + p) [
          "uploads"
          "backups"
          "tmp"
        ];

        StateDirectoryMode = "0750";
        TimeoutSec = "infinity";
        Type = "simple";
        User = "discourse";
        WorkingDirectory = "${cfg.package}/share/discourse";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.discourse-mail-receiver-setup = lib.mkIf cfg.mail.incoming.enable (
      let
        mail-receiver-environment = {
          DISCOURSE_API_KEY = "@api-key@";
          DISCOURSE_API_USERNAME = "system";
          DISCOURSE_BASE_URL = "http${lib.optionalString tlsEnabled "s"}://${cfg.hostname}";
          MAIL_DOMAIN = cfg.hostname;
        };
        mail-receiver-json = json.generate "mail-receiver.json" mail-receiver-environment;
      in
      {
        after = [ "discourse.service" ];
        before = [ "postfix.service" ];
        partOf = [ "discourse.service" ];

        path = [
          cfg.package.rake
          pkgs.jq
        ];

        preStart = lib.optionalString (cfg.mail.incoming.apiKeyFile == null) ''
          set -o errexit -o pipefail -o nounset -o errtrace
          shopt -s inherit_errexit

          if [[ ! -e /var/lib/discourse-mail-receiver/api_key ]]; then
              discourse-rake api_key:create_master[email-receiver] >/var/lib/discourse-mail-receiver/api_key
          fi
        '';

        script =
          let
            apiKeyPath =
              if cfg.mail.incoming.apiKeyFile == null then
                "/var/lib/discourse-mail-receiver/api_key"
              else
                cfg.mail.incoming.apiKeyFile;
          in
          ''
            set -o errexit -o pipefail -o nounset -o errtrace
            shopt -s inherit_errexit

            api_key=$(<'${apiKeyPath}')
            export api_key

            jq <${mail-receiver-json} \
               '.DISCOURSE_API_KEY = $ENV.api_key' \
               >'/run/discourse-mail-receiver/mail-receiver-environment.json'
          '';

        serviceConfig = {
          Group = "discourse";
          RemainAfterExit = true;
          RuntimeDirectory = "discourse-mail-receiver";
          RuntimeDirectoryMode = "0700";
          StateDirectory = "discourse-mail-receiver";
          Type = "oneshot";
          User = "discourse";
        };

        wantedBy = [ "discourse.service" ];
      }
    );

    # The postgresql module doesn't currently support concepts like
    # objects owners and extensions; for now we tack on what's needed
    # here.
    systemd.services.discourse-postgresql =
      let
        pgsql = config.services.postgresql;
      in
      lib.mkIf databaseActuallyCreateLocally {
        after = [ "postgresql.target" ];
        bindsTo = [ "postgresql.target" ];
        partOf = [ "discourse.service" ];

        path = [
          pgsql.package
        ];

        script = ''
          set -o errexit -o pipefail -o nounset -o errtrace
          shopt -s inherit_errexit

          psql -tAc "SELECT 1 FROM pg_database WHERE datname = 'discourse'" | grep -q 1 || psql -tAc 'CREATE DATABASE "discourse" OWNER "discourse"'
          psql '${cfg.database.name}' -tAc "CREATE EXTENSION IF NOT EXISTS pg_trgm"
          psql '${cfg.database.name}' -tAc "CREATE EXTENSION IF NOT EXISTS hstore"
          psql '${cfg.database.name}' -tAc "CREATE EXTENSION IF NOT EXISTS vector"
        '';

        serviceConfig = {
          RemainAfterExit = true;
          Type = "oneshot";
          User = pgsql.superUser;
        };

        wantedBy = [ "discourse.service" ];
      };

    users.groups = {
      discourse = { };
    };

    users.users = {
      discourse = {
        group = "discourse";
        isSystemUser = true;
      };
    }
    // (lib.optionalAttrs cfg.nginx.enable {
      ${config.services.nginx.user}.extraGroups = [ "discourse" ];
    });
  };

  meta.doc = ./discourse.md;
  meta.maintainers = [ lib.maintainers.talyz ];
}
