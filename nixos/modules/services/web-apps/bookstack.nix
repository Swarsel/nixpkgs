{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.bookstack;

  user = cfg.user;
  group = cfg.group;

  defaultUser = "bookstack";
  defaultGroup = "bookstack";

  artisan = "${cfg.package}/artisan";

  env-file-values = lib.mapAttrs' (n: v: {
    name = lib.removeSuffix "_FILE" n;
    value = v;
  }) (lib.filterAttrs (n: v: v != null && lib.match ".+_FILE" n != null) cfg.settings);

  env-nonfile-values = lib.filterAttrs (n: v: lib.match ".+_FILE" n == null) cfg.settings;

  bookstack-maintenance = pkgs.writeShellScript "bookstack-maintenance.sh" ''
    set -a
    ${lib.toShellVars env-nonfile-values}
    ${lib.concatLines (lib.mapAttrsToList (n: v: "${n}=\"$(< ${v})\"") env-file-values)}
    set +a
    ${artisan} optimize:clear
    rm ${cfg.dataDir}/cache/*.php
    ${artisan} package:discover
    ${artisan} migrate --force
    ${artisan} view:cache
    ${artisan} route:cache
    ${artisan} config:cache
  '';

  commonServiceConfig = {
    AmbientCapabilities = "";
    CapabilityBoundingSet = "";
    Group = group;
    LockPersonality = true;
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateNetwork = false;
    PrivateTmp = true;
    PrivateUsers = true;
    ProcSubset = "pid";
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = "tmpfs";
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    ProtectSystem = "strict";
    ReadWritePaths = [ cfg.dataDir ];
    RemoveIPC = true;
    RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX";
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    StateDirectory = "bookstack";
    SystemCallArchitectures = "native";

    SystemCallFilter = [
      "@system-service @resources"
      "~@obsolete @privileged"
    ];

    Type = "oneshot";
    User = user;
    WorkingDirectory = cfg.package;
  };

in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "bookstack"
      "extraConfig"
    ] "Use services.bookstack.settings instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "bookstack"
      "config"
    ] "Use services.bookstack.settings instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "bookstack"
      "cacheDir"
    ] "The cache directory is now handled automatically.")
    (lib.mkRemovedOptionModule [
      "services"
      "bookstack"
      "appKeyFile"
    ] "Use services.bookstack.settings.APP_KEY_FILE instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "bookstack"
      "appURL"
    ] "Use services.bookstack.settings.APP_URL instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "bookstack"
      "database"
      "host"
    ] "Use services.bookstack.settings.DB_HOST instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "bookstack"
      "database"
      "port"
    ] "Use services.bookstack.settings.DB_PORT instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "bookstack"
      "database"
      "passwordFile"
    ] "Use services.bookstack.settings.DB_PASSWORD_FILE instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "bookstack"
      "database"
      "name"
    ] "Use services.bookstack.settings.DB_DATABASE instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "bookstack"
      "database"
      "user"
    ] "Use services.bookstack.settings.DB_USERNAME instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "bookstack"
      "database"
      "createLocally"
    ] "Use services.mysql.ensureDatabases and services.mysql.ensureUsers instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "bookstack"
      "mail"
      "host"
    ] "Use services.bookstack.settings.MAIL_HOST instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "bookstack"
      "mail"
      "port"
    ] "Use services.bookstack.settings.MAIL_PORT instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "bookstack"
      "mail"
      "passwordFile"
    ] "Use services.bookstack.settings.MAIL_PASSWORD_FILE instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "bookstack"
      "mail"
      "name"
    ] "Use services.bookstack.settings.MAIL_DATABASE instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "bookstack"
      "mail"
      "user"
    ] "Use services.bookstack.settings.MAIL_USERNAME instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "bookstack"
      "mail"
      "driver"
    ] "Use services.bookstack.settings.MAIL_DRIVER instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "bookstack"
      "mail"
      "fromName"
    ] "Use services.bookstack.settings.MAIL_FROM_NAME instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "bookstack"
      "mail"
      "from"
    ] "Use services.bookstack.settings.MAIL_FROM instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "bookstack"
      "mail"
      "encryption"
    ] "Use services.bookstack.settings.MAIL_ENCRYPTION instead.")
  ];

  options.services.bookstack = {
    enable = lib.mkEnableOption "BookStack: A platform to create documentation/wiki content built with PHP & Laravel";

    package =
      lib.mkPackageOption pkgs "bookstack" { }
      // lib.mkOption {
        apply =
          bookstack:
          bookstack.override (prev: {
            dataDir = cfg.dataDir;
          });
      };

    dataDir = lib.mkOption {
      default = "/var/lib/bookstack";
      description = "BookStack data directory";
      type = lib.types.path;
    };

    group = lib.mkOption {
      default = if (cfg.nginx != null) then config.services.nginx.group else defaultGroup;
      defaultText = "If `services.bookstack.nginx` has any attributes then `nginx` else ${defaultGroup}";
      description = "Group bookstack runs as";
      type = lib.types.str;
    };

    hostname = lib.mkOption {
      default = config.networking.fqdnOrHostName;
      defaultText = lib.literalExpression "config.networking.fqdnOrHostName";

      description = ''
        The hostname to serve BookStack on.
      '';

      example = "bookstack.example.com";
      type = lib.types.str;
    };

    maxUploadSize = lib.mkOption {
      default = "18M";
      description = "The maximum size for uploads (e.g. images).";
      example = "1G";
      type = lib.types.str;
    };

    nginx = lib.mkOption {
      default = null;

      description = ''
        With this option, you can customize the nginx virtualHost settings.
      '';

      example = lib.literalExpression ''
        {
          serverAliases = [
            "bookstack.''${config.networking.domain}"
          ];
          # To enable encryption and let let's encrypt take care of certificate
          forceSSL = true;
          enableACME = true;
        }
      '';

      type = lib.types.nullOr (
        lib.types.submodule (
          lib.recursiveUpdate (import ../web-servers/nginx/vhost-options.nix { inherit config lib; }) { }
        )
      );
    };

    poolConfig = lib.mkOption {
      default = { };

      defaultText = ''
        {
          "pm" = "dynamic";
          "pm.max_children" = 32;
          "pm.start_servers" = 2;
          "pm.min_spare_servers" = 2;
          "pm.max_spare_servers" = 4;
          "pm.max_requests" = 500;
        }
      '';

      description = ''
        Options for the Bookstack PHP pool. See the documentation on `php-fpm.conf`
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

    settings = lib.mkOption {
      default = { };

      description = ''
        Options for Bookstack configuration. Refer to
        <https://github.com/BookStackApp/BookStack/blob/development/.env.example> for
        details on supported values. For passing secrets, append "_FILE" to the
        setting name. For example, you may create a file `/var/secrets/db_pass.txt`
        and set `services.bookstack.settings.DB_PASSWORD_FILE` to `/var/secrets/db_pass.txt`
        instead of providing a plaintext password using `services.bookstack.settings.DB_PASSWORD`.
      '';

      example = lib.literalExpression ''
        {
          APP_ENV = "production";
          APP_KEY_FILE = "/var/secrets/bookstack-app-key.txt";
          DB_HOST = "db";
          DB_PORT = 3306;
          DB_DATABASE = "bookstack";
          DB_USERNAME = "bookstack";
          DB_PASSWORD_FILE = "/var/secrets/bookstack-mysql-password.txt";
        }
      '';

      type = lib.types.submodule {
        options = {
          APP_KEY_FILE = lib.mkOption {
            description = ''
              The path to your appkey.
              The file should contain a 32 character random app key.
              This may be set using `echo "base64:$(head -c 32 /dev/urandom | base64)" > /path/to/key-file`.
            '';

            type = lib.types.path;
          };

          APP_URL = lib.mkOption {
            default =
              if cfg.hostname == "localhost" then "http://${cfg.hostname}" else "https://${cfg.hostname}";

            defaultText = "http(s)://\${config.services.bookstack.hostname}";

            description = ''
              The root URL that you want to host BookStack on. All URLs in BookStack
              will be generated using this value. It is used to validate specific
              requests and to generate URLs in emails.
            '';

            example = "https://example.com";
            type = lib.types.str;
          };

          DB_HOST = lib.mkOption {
            default = "localhost";

            description = ''
              The IP or hostname which hosts your database.
            '';

            type = lib.types.str;
          };

          DB_PASSWORD_FILE = lib.mkOption {
            default = null;

            description = ''
              The file containing your mysql/mariadb database password.
            '';

            example = "/var/secrets/bookstack-mysql-pass.txt";
            type = lib.types.nullOr lib.types.path;
          };

          DB_PORT = lib.mkOption {
            default = 3306;

            description = ''
              The port your database is listening at.
            '';

            type = lib.types.port;
          };
        };

        freeformType = lib.types.attrsOf (
          lib.types.oneOf [
            lib.types.str
            lib.types.int
            lib.types.bool
          ]
        );
      };
    };

    user = lib.mkOption {
      default = defaultUser;
      description = "User bookstack runs as";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {

    services.nginx = lib.mkIf (cfg.nginx != null) {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;

      virtualHosts.${cfg.hostname} = lib.mkMerge [
        cfg.nginx
        {
          locations = {
            "/" = {
              extraConfig = ''
                sendfile off;
              '';

              index = "index.php";
              root = "${cfg.package}/public";
              tryFiles = "$uri $uri/ /index.php?$query_string";
            };

            "~ \\.(js|css|gif|png|ico|jpg|jpeg)$" = {
              extraConfig = "expires 365d;";
              root = "${cfg.package}/public";
            };

            "~ \\.php$" = {
              extraConfig = ''
                include ${config.services.nginx.package}/conf/fastcgi_params;
                fastcgi_param SCRIPT_FILENAME $request_filename;
                fastcgi_param modHeadersAvailable true; # Avoid sending the security headers twice
                fastcgi_pass unix:${config.services.phpfpm.pools."bookstack".socket};
              '';

              root = "${cfg.package}/public";
            };
          };
        }
      ];
    };

    services.phpfpm.pools.bookstack = {
      inherit user group;

      phpOptions = ''
        log_errors = on
        post_max_size = ${cfg.maxUploadSize}
        upload_max_filesize = ${cfg.maxUploadSize}
      '';

      phpPackage = cfg.package.phpPackage;

      settings = {
        "listen.group" = lib.mkDefault group;
        "listen.mode" = lib.mkDefault "0660";
        "listen.owner" = lib.mkDefault user;
        "pm" = lib.mkDefault "dynamic";
        "pm.max_children" = lib.mkDefault 32;
        "pm.max_requests" = lib.mkDefault 500;
        "pm.max_spare_servers" = lib.mkDefault 4;
        "pm.min_spare_servers" = lib.mkDefault 2;
        "pm.start_servers" = lib.mkDefault 2;
      }
      // cfg.poolConfig;
    };

    systemd.services.bookstack-setup = {
      after = [ "mysql.service" ];
      before = [ "phpfpm-bookstack.service" ];
      partOf = [ "phpfpm-bookstack.service" ];
      requiredBy = [ "phpfpm-bookstack.service" ];
      restartTriggers = [ cfg.package ];

      serviceConfig = {
        ExecStart = bookstack-maintenance;
        RemainAfterExit = true;
      }
      // commonServiceConfig;

      unitConfig.JoinsNamespaceOf = "phpfpm-bookstack.service";
    };

    systemd.tmpfiles.settings."10-bookstack" =
      let
        defaultConfig = {
          inherit user group;
          mode = "0700";
        };
      in
      {
        "${cfg.dataDir}".d = defaultConfig // {
          mode = "0710";
        };

        "${cfg.dataDir}/cache".d = defaultConfig;

        "${cfg.dataDir}/public".d = defaultConfig // {
          mode = "0750";
        };

        "${cfg.dataDir}/public/uploads".d = defaultConfig // {
          mode = "0750";
        };

        "${cfg.dataDir}/storage".d = defaultConfig;
        "${cfg.dataDir}/storage/app".d = defaultConfig;
        "${cfg.dataDir}/storage/fonts".d = defaultConfig;
        "${cfg.dataDir}/storage/framework".d = defaultConfig;
        "${cfg.dataDir}/storage/framework/cache".d = defaultConfig;
        "${cfg.dataDir}/storage/framework/sessions".d = defaultConfig;
        "${cfg.dataDir}/storage/framework/views".d = defaultConfig;
        "${cfg.dataDir}/storage/logs".d = defaultConfig;
        "${cfg.dataDir}/storage/uploads".d = defaultConfig;
        "${cfg.dataDir}/themes".d = defaultConfig;
      };

    users = {
      groups = lib.mkIf (group == defaultGroup) {
        bookstack = { };
      };

      users = lib.mkIf (user == defaultUser) {
        bookstack = {
          inherit group;
          home = cfg.dataDir;
          isSystemUser = true;
        };
      };
    };
  };

  meta.maintainers = with lib.maintainers; [
    savyajha
  ];
}
