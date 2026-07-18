{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.firefly-iii;

  user = cfg.user;
  group = cfg.group;

  defaultUser = "firefly-iii";
  defaultGroup = "firefly-iii";

  artisan = "${cfg.package}/artisan";

  env-file-values = lib.attrsets.mapAttrs' (
    n: v: lib.attrsets.nameValuePair (lib.strings.removeSuffix "_FILE" n) v
  ) (lib.attrsets.filterAttrs (n: v: lib.strings.hasSuffix "_FILE" n) cfg.settings);
  env-nonfile-values = lib.attrsets.filterAttrs (n: v: !lib.strings.hasSuffix "_FILE" n) cfg.settings;

  firefly-iii-maintenance = pkgs.writeShellScript "firefly-iii-maintenance.sh" ''
    set -a
    ${lib.strings.toShellVars env-nonfile-values}
    ${lib.strings.concatLines (
      lib.attrsets.mapAttrsToList (n: v: "${n}=\"$(< ${v})\"") env-file-values
    )}
    set +a
    ${lib.optionalString (
      cfg.settings.DB_CONNECTION == "sqlite"
    ) "touch ${cfg.dataDir}/storage/database/database.sqlite"}
    ${artisan} optimize:clear
    rm ${cfg.dataDir}/cache/*.php
    ${artisan} package:discover
    ${artisan} firefly-iii:upgrade-database
    ${artisan} firefly-iii:laravel-passport-keys
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
    StateDirectory = "firefly-iii";
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

  options.services.firefly-iii = {

    enable = lib.mkEnableOption "Firefly III: A free and open source personal finance manager";

    package =
      lib.mkPackageOption pkgs "firefly-iii" { }
      // lib.mkOption {
        apply =
          firefly-iii:
          firefly-iii.override (prev: {
            dataDir = cfg.dataDir;
          });
      };

    dataDir = lib.mkOption {
      default = "/var/lib/firefly-iii";

      description = ''
        The place where firefly-iii stores its state.
      '';

      type = lib.types.path;
    };

    enableNginx = lib.mkOption {
      default = false;

      description = ''
        Whether to enable nginx or not. If enabled, an nginx virtual host will
        be created for access to firefly-iii. If not enabled, then you may use
        `''${config.services.firefly-iii.package}` as your document root in
        whichever webserver you wish to setup.
      '';

      type = lib.types.bool;
    };

    group = lib.mkOption {
      default = if cfg.enableNginx then "nginx" else defaultGroup;
      defaultText = "If `services.firefly-iii.enableNginx` is true then `nginx` else ${defaultGroup}";

      description = ''
        Group under which firefly-iii runs. It is best to set this to the group
        of whatever webserver is being used as the frontend.
      '';

      type = lib.types.str;
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
        Options for the Firefly III PHP pool. See the documentation on <literal>php-fpm.conf</literal>
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
        Options for firefly-iii configuration. Refer to
        <https://github.com/firefly-iii/firefly-iii/blob/main/.env.example> for
        details on supported values. All <option>_FILE values supported by
        upstream are supported here.

        APP_URL will be the same as `services.firefly-iii.virtualHost` if the
        former is unset in `services.firefly-iii.settings`.
      '';

      example = lib.literalExpression ''
        {
          APP_ENV = "production";
          APP_KEY_FILE = "/var/secrets/firefly-iii-app-key.txt";
          SITE_OWNER = "mail@example.com";
          DB_CONNECTION = "mysql";
          DB_HOST = "db";
          DB_PORT = 3306;
          DB_DATABASE = "firefly";
          DB_USERNAME = "firefly";
          DB_PASSWORD_FILE = "/var/secrets/firefly-iii-mysql-password.txt";
        }
      '';

      type = lib.types.submodule {
        options = {
          APP_ENV = lib.mkOption {
            default = "local";

            description = ''
              The app environment. It is recommended to keep this at "local".
              Possible values are "local", "production" and "testing"
            '';

            example = "production";

            type = lib.types.enum [
              "local"
              "production"
              "testing"
            ];
          };

          APP_KEY_FILE = lib.mkOption {
            description = ''
              The path to your appkey. The file should contain a 32 character
              random app key. This may be set using `echo "base64:$(head -c 32
              /dev/urandom | base64)" > /path/to/key-file`.
            '';

            type = lib.types.path;
          };

          APP_URL = lib.mkOption {
            default =
              if cfg.virtualHost == "localhost" then
                "http://${cfg.virtualHost}"
              else
                "https://${cfg.virtualHost}";

            defaultText = ''
              http(s)://''${config.services.firefly-iii.virtualHost}
            '';

            description = ''
              The APP_URL used by firefly-iii internally. Please make sure this
              URL matches the external URL of your Firefly III installation. It
              is used to validate specific requests and to generate URLs in
              emails.
            '';

            type = lib.types.str;
          };

          DB_CONNECTION = lib.mkOption {
            default = "sqlite";

            description = ''
              The type of database you wish to use. Can be one of "sqlite",
              "mysql" or "pgsql".
            '';

            example = "pgsql";

            type = lib.types.enum [
              "sqlite"
              "pgsql"
              "mysql"
            ];
          };

          DB_HOST = lib.mkOption {
            default = if cfg.settings.DB_CONNECTION == "pgsql" then "/run/postgresql" else "localhost";

            defaultText = ''
              "localhost" if DB_CONNECTION is "sqlite" or "mysql", "/run/postgresql" if "pgsql".
            '';

            description = ''
              The machine which hosts your database. This is left at the
              default value for "mysql" because we use the "DB_SOCKET" option
              to connect to a unix socket instead. "pgsql" requires that the
              unix socket location be specified here instead of at "DB_SOCKET".
              This option does not affect "sqlite".
            '';

            type = lib.types.str;
          };

          DB_PORT = lib.mkOption {
            default =
              if cfg.settings.DB_CONNECTION == "pgsql" then
                5432
              else if cfg.settings.DB_CONNECTION == "mysql" then
                3306
              else
                null;

            defaultText = ''
              `null` if DB_CONNECTION is "sqlite", `3306` if "mysql", `5432` if "pgsql"
            '';

            description = ''
              The port your database is listening at. sqlite does not require
              this value to be filled.
            '';

            type = lib.types.nullOr lib.types.int;
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
      description = "User account under which firefly-iii runs.";
      type = lib.types.str;
    };

    virtualHost = lib.mkOption {
      default = "localhost";

      description = ''
        The hostname at which you wish firefly-iii to be served. If you have
        enabled nginx using `services.firefly-iii.enableNginx` then this will
        be used.
      '';

      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {

    services.nginx = lib.mkIf cfg.enableNginx {
      enable = true;
      recommendedGzipSettings = lib.mkDefault true;
      recommendedOptimisation = lib.mkDefault true;
      recommendedTlsSettings = lib.mkDefault true;

      virtualHosts.${cfg.virtualHost} = {
        locations = {
          "/" = {
            extraConfig = ''
              sendfile off;
            '';

            index = "index.php";
            tryFiles = "$uri $uri/ /index.php?$query_string";
          };

          "~ \\.php$" = {
            extraConfig = ''
              include ${config.services.nginx.package}/conf/fastcgi_params ;
              fastcgi_param SCRIPT_FILENAME $request_filename;
              fastcgi_param modHeadersAvailable true; #Avoid sending the security headers twice
              fastcgi_pass unix:${config.services.phpfpm.pools.firefly-iii.socket};
            '';
          };
        };

        root = "${cfg.package}/public";
      };
    };

    services.phpfpm.pools.firefly-iii = {
      inherit user group;

      phpOptions = ''
        log_errors = on
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

    systemd.services.firefly-iii-cron = {
      after = [
        "firefly-iii-setup.service"
        "postgresql.target"
        "mysql.service"
      ];

      description = "Daily Firefly III cron job";

      serviceConfig = {
        ExecStart = "${artisan} firefly-iii:cron";
      }
      // commonServiceConfig;

      wants = [ "firefly-iii-setup.service" ];
    };

    systemd.services.firefly-iii-setup = {
      after = [
        "postgresql.target"
        "mysql.service"
      ];

      before = [ "phpfpm-firefly-iii.service" ];
      partOf = [ "phpfpm-firefly-iii.service" ];
      requiredBy = [ "phpfpm-firefly-iii.service" ];
      restartTriggers = [ cfg.package ];

      serviceConfig = {
        ExecStart = firefly-iii-maintenance;
        RemainAfterExit = true;
      }
      // commonServiceConfig;

      unitConfig.JoinsNamespaceOf = "phpfpm-firefly-iii.service";
    };

    systemd.timers.firefly-iii-cron = {
      description = "Trigger Firefly Cron";
      restartTriggers = [ cfg.package ];

      timerConfig = {
        OnCalendar = "Daily";
        Persistent = true;
        RandomizedDelaySec = "1800s";
      };

      wantedBy = [ "timers.target" ];
    };

    systemd.tmpfiles.settings."10-firefly-iii" =
      lib.attrsets.genAttrs
        [
          "${cfg.dataDir}/storage"
          "${cfg.dataDir}/storage/app"
          "${cfg.dataDir}/storage/database"
          "${cfg.dataDir}/storage/export"
          "${cfg.dataDir}/storage/framework"
          "${cfg.dataDir}/storage/framework/cache"
          "${cfg.dataDir}/storage/framework/sessions"
          "${cfg.dataDir}/storage/framework/views"
          "${cfg.dataDir}/storage/logs"
          "${cfg.dataDir}/storage/upload"
          "${cfg.dataDir}/cache"
        ]
        (n: {
          d = {
            group = group;
            mode = "0700";
            user = user;
          };
        })
      // {
        "${cfg.dataDir}".d = {
          group = group;
          mode = "0710";
          user = user;
        };
      };

    users = {
      groups = lib.mkIf (group == defaultGroup) { ${defaultGroup} = { }; };

      users = lib.mkIf (user == defaultUser) {
        ${defaultUser} = {
          inherit group;
          description = "Firefly-iii service user";
          home = cfg.dataDir;
          isSystemUser = true;
        };
      };
    };
  };
}
