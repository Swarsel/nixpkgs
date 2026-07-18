{
  config,
  lib,
  pkgs,
  ...
}:

let

  inherit (lib)
    generators
    mapAttrs
    mkDefault
    mkEnableOption
    mkIf
    mkPackageOption
    mkOption
    types
    ;

  cfg = config.services.grav;

  yamlFormat = pkgs.formats.yaml { };

  poolName = "grav";

  servedRoot = pkgs.runCommand "grav-served-root" { } ''
    cp --reflink=auto --no-preserve=mode -r ${cfg.package} $out

    for p in assets images user system/config; do
      rm -rf $out/$p
      ln -sf /var/lib/grav/$p $out/$p
    done
  '';

  systemSettingsYaml = yamlFormat.generate "grav-settings.yaml" cfg.systemSettings;

in
{
  options.services.grav = {
    enable = mkEnableOption "grav";
    package = mkPackageOption pkgs "grav" { };

    maxUploadSize = mkOption {
      default = "128M";

      description = ''
        The upload limit for files. This changes the relevant options in
        {file}`php.ini` and nginx if enabled.
      '';

      type = types.str;
    };

    phpPackage = mkPackageOption pkgs "php83" { };

    pool = mkOption {
      default = "${poolName}";

      description = ''
        Name of existing phpfpm pool that is used to run web-application.
        If not specified a pool will be created automatically with
        default values.
      '';

      type = types.str;
    };

    root = mkOption {
      default = "/var/lib/grav";

      description = ''
        Root of the application.
      '';

      type = types.path;
    };

    systemSettings = mkOption {
      default = {
        log = {
          handler = "syslog";
        };
      };

      description = ''
        Settings written to {file}`user/config/system.yaml`.
      '';

      type = yamlFormat.type;
    };

    virtualHost = mkOption {
      default = "grav";

      description = ''
        Name of the nginx virtualhost to use and setup. If null, do not setup
        any virtualhost.
      '';

      type = types.nullOr types.str;
    };
  };

  config = mkIf cfg.enable {
    services.nginx = mkIf (cfg.virtualHost != null) {
      enable = true;

      virtualHosts = {
        ${cfg.virtualHost} = {
          extraConfig = ''
            index index.php index.html /index.php$request_uri;
            add_header X-Content-Type-Options nosniff;
            add_header X-Download-Options noopen;
            add_header X-Permitted-Cross-Domain-Policies none;
            add_header X-Frame-Options sameorigin;
            add_header Referrer-Policy no-referrer;
            client_max_body_size ${cfg.maxUploadSize};
            fastcgi_buffers 64 4K;
            fastcgi_hide_header X-Powered-By;
            gzip on;
            gzip_vary on;
            gzip_comp_level 4;
            gzip_min_length 256;
            gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
            gzip_types application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;
          '';

          locations = {
            "/" = {
              extraConfig = ''
                try_files $uri $uri/ /index.php?$query_string;
              '';

              index = "index.php";
              priority = 400;
            };

            "= /robots.txt" = {
              extraConfig = ''
                allow all;
                access_log off;
              '';

              priority = 100;
            };

            # deny all files and folder beginning with a dot (hidden files & folders)
            "~ (^|/)\\." = {
              extraConfig = ''
                return 403;
              '';

              priority = 300;
            };

            # deny access to specific files in the root folder
            "~ /(LICENSE\\.txt|composer\\.lock|composer\\.json|nginx\\.conf|web\\.config|htaccess\\.txt|\\.htaccess)" =
              {
                extraConfig = ''
                  return 403;
                '';

                priority = 300;
              };

            "~ \\.php$" = {
              extraConfig = ''
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass unix:${config.services.phpfpm.pools.${cfg.pool}.socket};
                fastcgi_index index.php;
              '';

              priority = 200;
            };

            "~* /(\\.git|cache|bin|logs|backup|tests)/.*$" = {
              extraConfig = ''
                return 403;
              '';

              priority = 300;
            };

            # deny running scripts inside core system folders
            "~* /(system|vendor)/.*\\.(txt|xml|md|html|htm|shtml|shtm|json|yaml|yml|php|php2|php3|php4|php5|phar|phtml|pl|py|cgi|twig|sh|bat)$" =
              {
                extraConfig = ''
                  return 403;
                '';

                priority = 300;
              };

            # deny running scripts inside user folder
            "~* /user/.*\\.(txt|md|json|yaml|yml|php|php2|php3|php4|php5|phar|phtml|pl|py|cgi|twig|sh|bat)$" = {
              extraConfig = ''
                return 403;
              '';

              priority = 300;
            };
          };

          root = "${servedRoot}";
        };
      };
    };

    services.phpfpm.pools = mkIf (cfg.pool == "${poolName}") {
      ${poolName} = {
        group = "grav";

        phpEnv = {
          GRAV_BACKUP_PATH = "/var/lib/grav/backup";
          GRAV_CACHE_PATH = "/var/cache/grav";
          GRAV_LOG_PATH = "/var/log/grav";
          GRAV_ROOT = toString servedRoot;
          GRAV_SYSTEM_PATH = "${servedRoot}/system";
          GRAV_TMP_PATH = "/var/tmp/grav";
        };

        phpPackage = cfg.phpPackage.buildEnv {
          extensions =
            { all, enabled }:
            enabled
            ++ (with all; [
              apcu
              xml
              yaml
            ]);

          extraConfig = generators.toKeyValue { mkKeyValue = generators.mkKeyValueDefault { } " = "; } {
            "apc.enable_cli" = "1";
            catch_workers_output = "yes";
            display_errors = "stderr";
            error_reporting = "E_ALL";
            expose_php = "Off";
            memory_limit = cfg.maxUploadSize;
            "opcache.fast_shutdown" = "1";
            "opcache.interned_strings_buffer" = "8";
            "opcache.max_accelerated_files" = "10000";
            "opcache.memory_consumption" = "128";
            "opcache.revalidate_freq" = "1";
            "openssl.cafile" = config.security.pki.caBundle;
            output_buffering = "0";
            post_max_size = cfg.maxUploadSize;
            short_open_tag = "Off";
            upload_max_filesize = cfg.maxUploadSize;
          };
        };

        settings = mapAttrs (name: mkDefault) {
          "catch_workers_output" = 1;
          "listen.group" = config.services.nginx.group;
          "listen.mode" = "0600";
          "listen.owner" = config.services.nginx.user;
          "pm" = "dynamic";
          "pm.max_children" = 75;
          "pm.max_requests" = 500;
          "pm.max_spare_servers" = 20;
          "pm.min_spare_servers" = 5;
          "pm.start_servers" = 10;
        };

        user = "grav";
      };
    };

    systemd.services = {
      "phpfpm-${poolName}" = mkIf (cfg.pool == "${poolName}") {
        restartTriggers = [
          servedRoot
          systemSettingsYaml
        ];

        serviceConfig = {
          ExecStartPre = pkgs.writeShellScript "grav-pre-start" ''
            function setPermits() {
              chmod -R o-rx "$1"
              chown -R grav:grav "$1"
            }

            tmpDir=/var/tmp/grav
            dataDir=/var/lib/grav

            mkdir $tmpDir
            setPermits $tmpDir

            for path in config/site.yaml pages plugins themes; do
              fullPath="$dataDir/user/$path"
              if [[ ! -e $fullPath ]]; then
                cp --reflink=auto --no-preserve=mode -r \
                  ${cfg.package}/user/$path $fullPath
              fi
              setPermits $fullPath
            done

            systemConfigDir=$dataDir/system/config
            if [[ ! -e $systemConfigDir/system.yaml ]]; then
              cp --reflink=auto --no-preserve=mode -r \
                ${cfg.package}/system/config/* $systemConfigDir/
            fi
            setPermits $systemConfigDir
          '';
        };
      };
    };

    systemd.tmpfiles.rules =
      let
        datadir = "/var/lib/grav";
      in
      map (dir: "d '${dir}' 0750 grav grav - -") [
        "/var/cache/grav"
        "${datadir}/assets"
        "${datadir}/backup"
        "${datadir}/images"
        "${datadir}/system/config"
        "${datadir}/user/accounts"
        "${datadir}/user/config"
        "${datadir}/user/data"
        "/var/log/grav"
      ]
      ++ [ "L+ ${datadir}/user/config/system.yaml - - - - ${systemSettingsYaml}" ];

    users.groups.grav = {
      members = [ config.services.nginx.user ];
    };

    users.users.grav = {
      description = "Grav service user";
      group = "grav";
      home = "/var/lib/grav";
      isSystemUser = true;
    };
  };
}
