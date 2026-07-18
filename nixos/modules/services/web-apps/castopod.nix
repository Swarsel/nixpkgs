{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.castopod;
  fpm = config.services.phpfpm.pools.castopod;

  user = "castopod";

  # https://docs.castopod.org/getting-started/install.html#requirements
  phpPackage = pkgs.php82.withExtensions (
    { all, enabled }:
    with all;
    [
      intl
      curl
      mbstring
      gd
      exif
      mysqlnd
    ]
    ++ enabled
  );
in
{
  options.services = {
    castopod = {
      enable = lib.mkEnableOption "Castopod, a hosting platform for podcasters";
      package = lib.mkPackageOption pkgs "castopod" { };

      configureNginx = lib.mkOption {
        default = true;
        description = "Configure nginx as a reverse proxy for CastoPod.";
        type = lib.types.bool;
      };

      dataDir = lib.mkOption {
        default = "/var/lib/castopod";

        description = ''
          The path where castopod stores all data. This path must be in sync
          with the castopod package (where it is hardcoded during the build in
          accordance with its own `dataDir` argument).
        '';

        type = lib.types.path;
      };

      database = {
        createLocally = lib.mkOption {
          default = true;

          description = ''
            Create the database and database user locally.
          '';

          type = lib.types.bool;
        };

        hostname = lib.mkOption {
          default = "localhost";
          description = "Database hostname.";
          type = lib.types.str;
        };

        name = lib.mkOption {
          default = "castopod";
          description = "Database name.";
          type = lib.types.str;
        };

        passwordFile = lib.mkOption {
          default = null;

          description = ''
            A file containing the password corresponding to
            [](#opt-services.castopod.database.user).

            This file is loaded using systemd LoadCredentials.
          '';

          example = "/run/keys/castopod-dbpassword";
          type = lib.types.nullOr lib.types.path;
        };

        user = lib.mkOption {
          default = user;
          description = "Database user.";
          type = lib.types.str;
        };
      };

      environmentFile = lib.mkOption {
        default = null;

        description = ''
          Environment file to inject e.g. secrets into the configuration.
          See [](https://code.castopod.org/adaures/castopod/-/blob/main/.env.example)
          for available environment variables.

          This file is loaded using systemd LoadCredentials.
        '';

        example = "/run/keys/castopod-env";
        type = lib.types.nullOr lib.types.path;
      };

      localDomain = lib.mkOption {
        description = "The domain serving your CastoPod instance.";
        example = "castopod.example.org";
        type = lib.types.str;
      };

      maxUploadSize = lib.mkOption {
        default = "512M";

        description = ''
          Maximum supported size for a file upload in. Maximum HTTP body
          size is set to this value for nginx and PHP (because castopod doesn't
          support chunked uploads yet:
          https://code.castopod.org/adaures/castopod/-/issues/330).

          Note, that practical upload size limit is smaller. For example, with
          512 MiB setting - around 500 MiB is possible.
        '';

        type = lib.types.str;
      };

      poolSettings = lib.mkOption {
        default = {
          "pm" = "dynamic";
          "pm.max_children" = "32";
          "pm.max_requests" = "500";
          "pm.max_spare_servers" = "4";
          "pm.min_spare_servers" = "2";
          "pm.start_servers" = "2";
        };

        description = ''
          Options for Castopod's PHP pool. See the documentation on `php-fpm.conf` for details on configuration directives.
        '';

        type =
          with lib.types;
          attrsOf (oneOf [
            str
            int
            bool
          ]);
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Environment variables used for Castopod.
          See [](https://code.castopod.org/adaures/castopod/-/blob/main/.env.example)
          for available environment variables.
        '';

        example = {
          "email.SMTPHost" = "localhost";
          "email.SMTPUser" = "myuser";
          "email.fromEmail" = "castopod@example.com";
          "email.protocol" = "smtp";
        };

        type =
          with lib.types;
          attrsOf (oneOf [
            str
            int
            bool
          ]);
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.castopod.settings =
      let
        sslEnabled =
          with config.services.nginx.virtualHosts.${cfg.localDomain};
          addSSL || forceSSL || onlySSL || enableACME || useACMEHost != null;
        baseURL = "http${lib.optionalString sslEnabled "s"}://${cfg.localDomain}";
      in
      lib.mapAttrs (_: lib.mkDefault) {
        "admin.gateway" = "admin";
        "app.baseURL" = baseURL;
        "app.forceGlobalSecureRequests" = sslEnabled;
        "auth.gateway" = "auth";
        "cache.handler" = "file";
        "database.default.DBPrefix" = "cp_";
        "database.default.database" = cfg.database.name;
        "database.default.hostname" = cfg.database.hostname;
        "database.default.username" = cfg.database.user;
        "media.baseURL" = baseURL;
        "media.root" = "media";
        "media.storage" = cfg.dataDir;
      };

    services.mysql = lib.mkIf cfg.database.createLocally {
      enable = true;
      package = lib.mkDefault pkgs.mariadb;
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

    services.nginx = lib.mkIf cfg.configureNginx {
      enable = true;

      virtualHosts."${cfg.localDomain}" = {
        extraConfig = ''
          try_files $uri $uri/ /index.php?$args;
          index index.php index.html;
          client_max_body_size ${cfg.maxUploadSize};
        '';

        locations."^~ /${cfg.settings."media.root"}/" = {
          extraConfig = ''
            add_header Access-Control-Allow-Origin "*";
            expires max;
            access_log off;
          '';

          root = cfg.settings."media.storage";
        };

        locations."~ \\.php$" = {
          extraConfig = ''
            fastcgi_intercept_errors on;
            fastcgi_index index.php;
            fastcgi_pass unix:${fpm.socket};
            try_files $uri =404;
            fastcgi_read_timeout 3600;
            fastcgi_send_timeout 3600;
          '';

          fastcgiParams = {
            SERVER_NAME = "$host";
          };
        };

        root = lib.mkForce "${cfg.package}/share/castopod/public";
      };
    };

    services.phpfpm.pools.castopod = {
      inherit user;
      inherit phpPackage;
      group = config.services.nginx.group;

      phpOptions = ''
        # https://code.castopod.org/adaures/castopod/-/blob/develop/docker/production/common/uploads.template.ini
        file_uploads = On
        memory_limit = 512M
        upload_max_filesize = ${cfg.maxUploadSize}
        post_max_size = ${cfg.maxUploadSize}
        max_execution_time = 300
        max_input_time = 300
      '';

      settings = {
        "listen.group" = config.services.nginx.group;
        "listen.owner" = config.services.nginx.user;
      }
      // cfg.poolSettings;
    };

    systemd.services.castopod-scheduled = {
      after = [ "castopod-setup.service" ];
      path = [ phpPackage ];

      script = ''
        php ${cfg.package}/share/castopod/spark tasks:run
      '';

      serviceConfig = {
        Group = config.services.nginx.group;
        LogLevelMax = "notice"; # otherwise periodic tasks flood the journal
        ReadWritePaths = cfg.dataDir;
        StateDirectory = "castopod";
        Type = "oneshot";
        User = user;
        WorkingDirectory = "${cfg.package}/share/castopod";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.castopod-setup = {
      after = lib.optional config.services.mysql.enable "mysql.service";

      path = [
        pkgs.openssl
        phpPackage
      ];

      requires = lib.optional config.services.mysql.enable "mysql.service";

      script =
        let
          envFile = "${cfg.dataDir}/.env";
          media = "${cfg.settings."media.storage"}/${cfg.settings."media.root"}";
        in
        ''
          mkdir -p ${cfg.dataDir}/writable/{cache,logs,session,temp,uploads}

          if [ ! -d ${lib.escapeShellArg media} ]; then
            cp --no-preserve=mode,ownership -r ${cfg.package}/share/castopod/public/media ${lib.escapeShellArg media}
          fi

          if [ ! -f ${cfg.dataDir}/salt ]; then
            openssl rand -base64 33 > ${cfg.dataDir}/salt
          fi

          cat <<'EOF' > ${envFile}
          ${lib.generators.toKeyValue { } cfg.settings}
          EOF

          echo "analytics.salt=$(cat ${cfg.dataDir}/salt)" >> ${envFile}

          ${
            if (cfg.database.passwordFile != null) then
              ''
                echo "database.default.password=$(<"$CREDENTIALS_DIRECTORY/dbpasswordfile")" >> ${envFile}
              ''
            else
              ''
                echo "database.default.password=" >> ${envFile}
              ''
          }

          ${lib.optionalString (cfg.environmentFile != null) ''
            cat "$CREDENTIALS_DIRECTORY/envfile" >> ${envFile}
          ''}

          php ${cfg.package}/share/castopod/spark castopod:database-update
        '';

      serviceConfig = {
        Group = config.services.nginx.group;

        LoadCredential =
          lib.optional (cfg.environmentFile != null) "envfile:${cfg.environmentFile}"
          ++ (lib.optional (cfg.database.passwordFile != null) "dbpasswordfile:${cfg.database.passwordFile}");

        ReadWritePaths = cfg.dataDir;
        RemainAfterExit = true;
        StateDirectory = "castopod";
        Type = "oneshot";
        User = user;
        WorkingDirectory = "${cfg.package}/share/castopod";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.timers.castopod-scheduled = {
      timerConfig = {
        OnCalendar = "*-*-* *:*:00";
        Unit = "castopod-scheduled.service";
      };

      wantedBy = [ "timers.target" ];
    };

    users.users.${user} = lib.mapAttrs (_: lib.mkDefault) {
      description = "Castopod user";
      group = config.services.nginx.group;
      isSystemUser = true;
    };
  };

  meta.doc = ./castopod.md;
  meta.maintainers = with lib.maintainers; [ alexoundos ];
}
