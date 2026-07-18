{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.pixelfed;
  user = cfg.user;
  group = cfg.group;
  pixelfed = cfg.package.override { inherit (cfg) dataDir runtimeDir; };
  # https://github.com/pixelfed/pixelfed/blob/dev/app/Console/Commands/Installer.php#L185-L190
  extraPrograms = with pkgs; [
    jpegoptim
    optipng
    pngquant
    gifsicle
    ffmpeg
  ];
  # Ensure PHP extensions: https://github.com/pixelfed/pixelfed/blob/dev/app/Console/Commands/Installer.php#L135-L147
  phpPackage = cfg.phpPackage.buildEnv {
    extensions =
      { all, enabled }:
      enabled
      ++ (with all; [
        bcmath
        ctype
        curl
        mbstring
        gd
        intl
        zip
        redis
        imagick
      ]);
  };
  configFile = pkgs.writeText "pixelfed-env" (lib.generators.toKeyValue { } cfg.settings);
  # Management script
  pixelfed-manage = pkgs.writeShellScriptBin "pixelfed-manage" ''
    cd ${pixelfed}
    sudo=exec
    if [[ "$USER" != ${user} ]]; then
      sudo='exec /run/wrappers/bin/sudo -u ${user}'
    fi
    $sudo ${phpPackage}/bin/php artisan "$@"
  '';
  dbSocket =
    {
      "mysql" = "/run/mysqld/mysqld.sock";
      "pgsql" = "/run/postgresql";
    }
    .${cfg.database.type};
  dbUnit =
    {
      "mysql" = "mysql.service";
      "pgsql" = "postgresql.target";
    }
    .${cfg.database.type};
  redisService = "redis-pixelfed.service";
in
{
  options.services = {
    pixelfed = {
      enable = mkEnableOption "a Pixelfed instance";
      package = mkPackageOption pkgs "pixelfed" { };

      dataDir = mkOption {
        default = "/var/lib/pixelfed";

        description = ''
          State directory of the `pixelfed` user which holds
          the application's state and data.
        '';

        type = types.str;
      };

      database = {
        automaticMigrations = mkEnableOption "automatic migrations for database schema and data" // {
          default = true;
        };

        createLocally = mkEnableOption "a local database using UNIX socket authentication" // {
          default = true;
        };

        name = mkOption {
          default = "pixelfed";
          description = "Database name.";
          type = types.str;
        };

        type = mkOption {
          default = "mysql";

          description = ''
            Database engine to use.
            Note that PGSQL is not well supported: <https://github.com/pixelfed/pixelfed/issues/2727>
          '';

          example = "pgsql";

          type = types.enum [
            "mysql"
            "pgsql"
          ];
        };
      };

      domain = mkOption {
        description = ''
          FQDN for the Pixelfed instance.
        '';

        type = types.str;
      };

      group = mkOption {
        default = "pixelfed";

        description = ''
          Group account under which pixelfed runs.

          ::: {.note}
          If left as the default value this group will automatically be created
          on system activation, otherwise you are responsible for
          ensuring the group exists before the pixelfed application starts.
          :::
        '';

        type = types.str;
      };

      maxUploadSize = mkOption {
        default = "8M";

        description = ''
          Max upload size with units.
        '';

        type = types.str;
      };

      nginx = mkOption {
        default = null;

        description = ''
          With this option, you can customize an nginx virtual host which already has sensible defaults for Pixelfed.
          Set to {} if you do not need any customization to the virtual host.
          If enabled, then by default, the {option}`serverName` is
          `''${domain}`,
          If this is set to null (the default), no nginx virtualHost will be configured.
        '';

        example = lib.literalExpression ''
          {
            serverAliases = [
              "pics.''${config.networking.domain}"
            ];
            enableACME = true;
            forceSSL = true;
          }
        '';

        type = types.nullOr (
          types.submodule (
            import ../web-servers/nginx/vhost-options.nix {
              inherit config lib;
            }
          )
        );
      };

      phpPackage = mkPackageOption pkgs "php83" { };

      poolConfig = mkOption {
        default = { };

        description = ''
          Options for Pixelfed's PHP-FPM pool.
        '';

        type =
          with types;
          attrsOf (oneOf [
            int
            str
            bool
          ]);
      };

      redis.createLocally = mkEnableOption "a local Redis database using UNIX socket authentication" // {
        default = true;
      };

      runtimeDir = mkOption {
        default = "/run/pixelfed";

        description = ''
          Ruutime directory of the `pixelfed` user which holds
          the application's caches and temporary files.
        '';

        type = types.str;
      };

      schedulerInterval = mkOption {
        default = "1d";
        description = "How often the Pixelfed cron task should run";
        type = types.str;
      };

      secretFile = mkOption {
        description = ''
          A secret file to be sourced for the .env settings.
          Place `APP_KEY` and other settings that should not end up in the Nix store here.
        '';

        type = types.path;
      };

      settings = mkOption {
        description = ''
          .env settings for Pixelfed.
          Secrets should use `secretFile` option instead.
        '';

        type =
          with types;
          (attrsOf (oneOf [
            bool
            int
            str
          ]));
      };

      user = mkOption {
        default = "pixelfed";

        description = ''
          User account under which pixelfed runs.

          ::: {.note}
          If left as the default value this user will automatically be created
          on system activation, otherwise you are responsible for
          ensuring the user exists before the pixelfed application starts.
          :::
        '';

        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pixelfed-manage ];

    services.mysql = mkIf (cfg.database.createLocally && cfg.database.type == "mysql") {
      enable = mkDefault true;
      package = mkDefault pkgs.mariadb;
      ensureDatabases = [ cfg.database.name ];

      ensureUsers = [
        {
          ensurePermissions = {
            "${cfg.database.name}.*" = "ALL PRIVILEGES";
          };

          name = user;
        }
      ];
    };

    services.nginx = mkIf (cfg.nginx != null) {
      enable = true;

      virtualHosts."${cfg.domain}" = mkMerge [
        cfg.nginx
        {
          extraConfig = ''
            add_header X-Frame-Options "SAMEORIGIN";
            add_header X-Content-Type-Options "nosniff";
            index index.html index.htm index.php;
            error_page 404 /index.php;
            client_max_body_size ${toString cfg.maxUploadSize};
          '';

          locations."/".tryFiles = "$uri $uri/ /index.php?$query_string";

          locations."/favicon.ico".extraConfig = ''
            access_log off; log_not_found off;
          '';

          locations."/robots.txt".extraConfig = ''
            access_log off; log_not_found off;
          '';

          locations."~ /\\.(?!well-known).*".extraConfig = ''
            deny all;
          '';

          locations."~ \\.php$".extraConfig = ''
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:${config.services.phpfpm.pools.pixelfed.socket};
            fastcgi_index index.php;
          '';

          root = lib.mkForce "${pixelfed}/public/";
        }
      ];
    };

    services.phpfpm.pools.pixelfed = {
      inherit user group;
      inherit phpPackage;

      phpOptions = ''
        post_max_size = ${toString cfg.maxUploadSize}
        upload_max_filesize = ${toString cfg.maxUploadSize}
        max_execution_time = 600;
      '';

      settings = {
        "catch_workers_output" = "yes";
        "listen.group" = group;
        "listen.mode" = "0660";
        "listen.owner" = user;
      }
      // cfg.poolConfig;
    };

    # Make each individual option overridable with lib.mkDefault.
    services.pixelfed.poolConfig = lib.mapAttrs' (n: v: lib.nameValuePair n (lib.mkDefault v)) {
      "catch_workers_output" = true;
      "php_admin_flag[log_errors]" = true;
      "php_admin_value[error_log]" = "stderr";
      "pm" = "dynamic";
      "pm.max_children" = "32";
      "pm.max_requests" = "500";
      "pm.max_spare_servers" = "4";
      "pm.min_spare_servers" = "2";
      "pm.start_servers" = "2";
    };

    services.pixelfed.settings = mkMerge [
      {
        # ActivityPub: https://github.com/pixelfed/pixelfed/blob/dev/app/Console/Commands/Installer.php#L360-L364
        ACTIVITY_PUB = mkDefault true;
        ADMIN_DOMAIN = mkDefault cfg.domain;
        APP_DEBUG = mkDefault false;
        APP_DOMAIN = mkDefault cfg.domain;
        APP_ENV = mkDefault "production";
        # https://github.com/pixelfed/pixelfed/blob/dev/app/Console/Commands/Installer.php#L312-L316
        APP_URL = mkDefault "https://${cfg.domain}";
        AP_INBOX = mkDefault true;
        AP_OUTBOX = mkDefault true;
        AP_REMOTE_FOLLOW = mkDefault true;
        AP_SHAREDINBOX = mkDefault true;
        # https://github.com/pixelfed/pixelfed/blob/dev/app/Console/Commands/Installer.php#L351
        EXP_EMC = mkDefault true;
        IMAGE_DRIVER = mkDefault "imagick";
        # Defer to systemd
        LOG_CHANNEL = mkDefault "stderr";
        # Mobile APIs
        OAUTH_ENABLED = mkDefault true;
        OPEN_REGISTRATION = mkDefault false;
        # Image optimization: https://github.com/pixelfed/pixelfed/blob/dev/app/Console/Commands/Installer.php#L367-L404
        PF_OPTIMIZE_IMAGES = mkDefault true;
        SESSION_DOMAIN = mkDefault cfg.domain;
        SESSION_SECURE_COOKIE = mkDefault true;
        # TODO: find out the correct syntax?
        # TRUST_PROXIES = mkDefault "127.0.0.1/8, ::1/128";
      }
      (mkIf (cfg.redis.createLocally) {
        BROADCAST_DRIVER = mkDefault "redis";
        CACHE_DRIVER = mkDefault "redis";
        QUEUE_DRIVER = mkDefault "redis";
        REDIS_HOST = config.services.redis.servers.pixelfed.unixSocket;
        REDIS_PATH = config.services.redis.servers.pixelfed.unixSocket;
        # Support phpredis and predis configuration-style.
        REDIS_SCHEME = "unix";
        SESSION_DRIVER = mkDefault "redis";
        WEBSOCKET_REPLICATION_MODE = mkDefault "redis";
      })
      (mkIf (cfg.database.createLocally) {
        DB_CONNECTION = cfg.database.type;
        DB_DATABASE = cfg.database.name;
        # No TCP/IP connection.
        DB_PORT = 0;
        DB_SOCKET = dbSocket;
        DB_USERNAME = user;
      })
    ];

    services.postgresql = mkIf (cfg.database.createLocally && cfg.database.type == "pgsql") {
      enable = mkDefault true;
      ensureDatabases = [ cfg.database.name ];

      ensureUsers = [
        {
          name = user;
        }
      ];
    };

    services.redis.servers.pixelfed.enable = lib.mkIf cfg.redis.createLocally true;
    systemd.services.phpfpm-pixelfed.after = [ "pixelfed-data-setup.service" ];
    # Ensure image optimizations programs are available.
    systemd.services.phpfpm-pixelfed.path = extraPrograms;

    systemd.services.phpfpm-pixelfed.requires = [
      "pixelfed-horizon.service"
      "pixelfed-data-setup.service"
    ]
    ++ lib.optional cfg.database.createLocally dbUnit
    ++ lib.optional cfg.redis.createLocally redisService;

    systemd.services.pixelfed-cron = {
      description = "Pixelfed periodic tasks";
      # Ensure image optimizations programs are available.
      path = extraPrograms;

      serviceConfig = {
        ExecStart = "${pixelfed-manage}/bin/pixelfed-manage schedule:run";
        Group = group;
        StateDirectory = lib.mkIf (cfg.dataDir == "/var/lib/pixelfed") "pixelfed";
        User = user;
      };
    };

    systemd.services.pixelfed-data-setup = {
      after = lib.optional cfg.database.createLocally dbUnit;
      description = "Pixelfed setup: migrations, environment file update, cache reload, data changes";

      path =
        with pkgs;
        [
          bash
          pixelfed-manage
          rsync
        ]
        ++ extraPrograms;

      requires = lib.optional cfg.database.createLocally dbUnit;

      script = ''
        # Before running any PHP program, cleanup the code cache.
        # It's necessary if you upgrade the application otherwise you might
        # try to import non-existent modules.
        rm -f ${cfg.runtimeDir}/app.php
        rm -rf ${cfg.runtimeDir}/cache/*

        # Concatenate non-secret .env and secret .env
        rm -f ${cfg.dataDir}/.env
        cp --no-preserve=all ${configFile} ${cfg.dataDir}/.env
        echo -e '\n' >> ${cfg.dataDir}/.env
        cat "$CREDENTIALS_DIRECTORY/env-secrets" >> ${cfg.dataDir}/.env

        # Link the static storage (package provided) to the runtime storage
        # Necessary for cities.json and static images.
        mkdir -p ${cfg.dataDir}/storage
        rsync -av --no-perms ${pixelfed}/storage-static/ ${cfg.dataDir}/storage
        chmod -R +w ${cfg.dataDir}/storage

        chmod g+x ${cfg.dataDir}/storage ${cfg.dataDir}/storage/app
        chmod -R g+rX ${cfg.dataDir}/storage/app/public

        # Link the app.php in the runtime folder.
        # We cannot link the cache folder only because bootstrap folder needs to be writeable.
        ln -sf ${pixelfed}/bootstrap-static/app.php ${cfg.runtimeDir}/app.php

        # https://laravel.com/docs/10.x/filesystem#the-public-disk
        # Creating the public/storage → storage/app/public link
        # is unnecessary as it's part of the installPhase of pixelfed.

        # Install Horizon
        # FIXME: require write access to public/ — should be done as part of install — pixelfed-manage horizon:publish

        # Perform the first migration.
        [[ ! -f ${cfg.dataDir}/.initial-migration ]] && pixelfed-manage migrate --force && touch ${cfg.dataDir}/.initial-migration

        ${lib.optionalString cfg.database.automaticMigrations ''
          # Force migrate the database.
          pixelfed-manage migrate --force
        ''}

        # Import location data
        pixelfed-manage import:cities

        ${lib.optionalString cfg.settings.ACTIVITY_PUB ''
          # ActivityPub federation bookkeeping
          [[ ! -f ${cfg.dataDir}/.instance-actor-created ]] && pixelfed-manage instance:actor && touch ${cfg.dataDir}/.instance-actor-created
        ''}

        ${lib.optionalString cfg.settings.OAUTH_ENABLED ''
          # Generate Passport encryption keys
          [[ ! -f ${cfg.dataDir}/.passport-keys-generated ]] && pixelfed-manage passport:keys && touch ${cfg.dataDir}/.passport-keys-generated
        ''}

        pixelfed-manage route:cache
        pixelfed-manage view:cache
        pixelfed-manage config:cache
      '';

      serviceConfig = {
        Group = group;
        LoadCredential = "env-secrets:${cfg.secretFile}";
        StateDirectory = lib.mkIf (cfg.dataDir == "/var/lib/pixelfed") "pixelfed";
        Type = "oneshot";
        UMask = "077";
        User = user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.pixelfed-horizon = {
      after = [
        "network.target"
        "pixelfed-data-setup.service"
      ];

      description = "Pixelfed task queueing via Laravel Horizon framework";
      # Ensure image optimizations programs are available.
      path = extraPrograms;

      requires = [
        "pixelfed-data-setup.service"
      ]
      ++ (lib.optional cfg.database.createLocally dbUnit)
      ++ (lib.optional cfg.redis.createLocally redisService);

      serviceConfig = {
        ExecStart = "${pixelfed-manage}/bin/pixelfed-manage horizon";
        Group = group;
        Restart = "on-failure";
        StateDirectory = lib.mkIf (cfg.dataDir == "/var/lib/pixelfed") "pixelfed";
        Type = "simple";
        User = user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.timers.pixelfed-cron = {
      after = [ "pixelfed-data-setup.service" ];
      description = "Pixelfed periodic tasks timer";
      requires = [ "phpfpm-pixelfed.service" ];

      timerConfig = {
        OnBootSec = cfg.schedulerInterval;
        OnUnitActiveSec = cfg.schedulerInterval;
      };

      wantedBy = [ "timers.target" ];
    };

    systemd.tmpfiles.rules = [
      # Cache must live across multiple systemd units runtimes.
      "d ${cfg.runtimeDir}/                         0700 ${user} ${group} - -"
      "d ${cfg.runtimeDir}/cache                    0700 ${user} ${group} - -"
    ];

    users.groups.pixelfed = mkIf (cfg.group == "pixelfed") { };
    # Enable NGINX to access our phpfpm-socket.
    users.users."${config.services.nginx.user}".extraGroups = [ cfg.group ];

    users.users.pixelfed = mkIf (cfg.user == "pixelfed") {
      extraGroups = lib.optional cfg.redis.createLocally "redis-pixelfed";
      group = cfg.group;
      isSystemUser = true;
    };
  };
}
