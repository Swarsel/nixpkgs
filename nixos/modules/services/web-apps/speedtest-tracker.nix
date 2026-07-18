{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.speedtest-tracker;

  user = cfg.user;
  group = cfg.group;

  defaultUser = "speedtest-tracker";
  defaultGroup = "speedtest-tracker";

  artisan = "${cfg.package}/artisan";

  env-file-values = lib.mapAttrs' (n: v: {
    name = lib.removeSuffix "_FILE" n;
    value = v;
  }) (lib.filterAttrs (n: v: v != null && lib.match ".+_FILE" n != null) cfg.settings);

  env-nonfile-values = lib.filterAttrs (n: v: lib.match ".+_FILE" n == null) cfg.settings;

  speedtest-tracker-maintenance = pkgs.writeShellScript "speedtest-tracker-maintenance.sh" ''
    set -a
    ${lib.toShellVars env-nonfile-values}
    ${lib.concatLines (lib.mapAttrsToList (n: v: "${n}=\"$(< ${v})\"") env-file-values)}
    set +a
    ${lib.optionalString (
      cfg.settings.DB_CONNECTION == "sqlite"
    ) "touch ${cfg.dataDir}/storage/database/database.sqlite"}
    rm -f ${cfg.dataDir}/cache/*.php
    ${artisan} package:discover
    ${artisan} migrate --force
    ${artisan} optimize:clear
    ${artisan} view:cache
    ${artisan} config:cache
  '';

  speedtest-tracker-env-script =
    command:
    pkgs.writeShellScript "speedtest-tracker-${builtins.replaceStrings [ ":" " " ] [ "-" "-" ] command}.sh" ''
      set -a
      ${lib.toShellVars env-nonfile-values}
      ${lib.concatLines (lib.mapAttrsToList (n: v: "${n}=\"$(< ${v})\"") env-file-values)}
      set +a
      exec ${artisan} ${command}
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
    StateDirectory = "speedtest-tracker";
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
  options.services.speedtest-tracker = {

    enable = lib.mkEnableOption "Speedtest Tracker: A self-hosted internet performance tracking application";

    package =
      lib.mkPackageOption pkgs "speedtest-tracker" { }
      // lib.mkOption {
        apply =
          speedtest-tracker:
          speedtest-tracker.override (prev: {
            dataDir = cfg.dataDir;
          });
      };

    dataDir = lib.mkOption {
      default = "/var/lib/speedtest-tracker";

      description = ''
        The place where Speedtest Tracker stores its state.
      '';

      type = lib.types.path;
    };

    enableNginx = lib.mkOption {
      default = false;

      description = ''
        Whether to enable nginx or not. If enabled, an nginx virtual host will
        be created for access to Speedtest Tracker. If not enabled, then you may use
        `''${config.services.speedtest-tracker.package}` as your document root in
        whichever webserver you wish to setup.
      '';

      type = lib.types.bool;
    };

    group = lib.mkOption {
      default = if cfg.enableNginx then "nginx" else defaultGroup;
      defaultText = "If `services.speedtest-tracker.enableNginx` is true then `nginx` else ${defaultGroup}";

      description = ''
        Group under which Speedtest Tracker runs. It is best to set this to the group
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
        Options for the Speedtest Tracker PHP pool. See the documentation on `php-fpm.conf`
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
        Options for Speedtest Tracker configuration. Refer to
        <https://github.com/alexjustesen/speedtest-tracker> for
        details on supported values. All `_FILE` values are supported:
        append `_FILE` to the setting name to provide a path to a file
        containing the secret value.
      '';

      example = lib.literalExpression ''
        {
          APP_KEY_FILE = "/var/secrets/speedtest-tracker-app-key.txt";
          DB_CONNECTION = "mysql";
          DB_HOST = "db";
          DB_PORT = 3306;
          DB_DATABASE = "speedtest-tracker";
          DB_USERNAME = "speedtest-tracker";
          DB_PASSWORD_FILE = "/var/secrets/speedtest-tracker-mysql-password.txt";
        }
      '';

      type = lib.types.submodule {
        options = {
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
              http(s)://''${config.services.speedtest-tracker.virtualHost}
            '';

            description = ''
              The APP_URL used by Speedtest Tracker internally. Please make sure this
              URL matches the external URL of your installation. It is used to
              validate specific requests and to generate URLs in notifications.
            '';

            type = lib.types.str;
          };

          DB_CONNECTION = lib.mkOption {
            default = "sqlite";

            description = ''
              The type of database you wish to use. Can be one of "sqlite",
              "mysql", "mariadb" or "pgsql".
            '';

            example = "pgsql";

            type = lib.types.enum [
              "sqlite"
              "mysql"
              "mariadb"
              "pgsql"
            ];
          };

          DB_DATABASE = lib.mkOption {
            default =
              if cfg.settings.DB_CONNECTION == "sqlite" then
                "${cfg.dataDir}/storage/database/database.sqlite"
              else
                "speedtest-tracker";

            defaultText = ''
              "''${config.services.speedtest-tracker.dataDir}/storage/database/database.sqlite" if DB_CONNECTION is "sqlite", "speedtest-tracker" otherwise
            '';

            description = ''
              The name of the database, or path to the sqlite file.
            '';

            type = lib.types.str;
          };

          DB_HOST = lib.mkOption {
            default = "localhost";

            description = ''
              The IP or hostname which hosts your database.
            '';

            type = lib.types.str;
          };

          DB_PORT = lib.mkOption {
            default =
              if cfg.settings.DB_CONNECTION == "pgsql" then
                5432
              else if cfg.settings.DB_CONNECTION == "mysql" || cfg.settings.DB_CONNECTION == "mariadb" then
                3306
              else
                null;

            defaultText = ''
              `null` if DB_CONNECTION is "sqlite", `3306` if "mysql" or "mariadb", `5432` if "pgsql"
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
      description = "User account under which Speedtest Tracker runs.";
      type = lib.types.str;
    };

    virtualHost = lib.mkOption {
      default = "localhost";

      description = ''
        The hostname at which you wish Speedtest Tracker to be served. If you have
        enabled nginx using `services.speedtest-tracker.enableNginx` then this will
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

          "~ \\.(js|css|gif|png|ico|jpg|jpeg)$" = {
            extraConfig = "expires 365d;";
          };

          "~ \\.php$" = {
            extraConfig = ''
              include ${config.services.nginx.package}/conf/fastcgi_params;
              fastcgi_param SCRIPT_FILENAME $request_filename;
              fastcgi_param modHeadersAvailable true;
              fastcgi_pass unix:${config.services.phpfpm.pools.speedtest-tracker.socket};
            '';
          };
        };

        root = "${cfg.package}/public";
      };
    };

    services.phpfpm.pools.speedtest-tracker = {
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

    systemd.services.speedtest-tracker-queue-worker = {
      after = [ "speedtest-tracker-setup.service" ];
      description = "Speedtest Tracker queue worker";
      path = [ pkgs.ookla-speedtest ];

      serviceConfig = commonServiceConfig // {
        ExecStart = speedtest-tracker-env-script "queue:work --sleep=3 --tries=3";
        Restart = "always";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "speedtest-tracker-setup.service" ];
    };

    systemd.services.speedtest-tracker-scheduler = {
      after = [ "speedtest-tracker-setup.service" ];
      description = "Speedtest Tracker scheduler";
      path = [ pkgs.ookla-speedtest ];

      serviceConfig = {
        ExecStart = speedtest-tracker-env-script "schedule:run";
      }
      // commonServiceConfig;

      wants = [ "speedtest-tracker-setup.service" ];
    };

    systemd.services.speedtest-tracker-setup = {
      after = [
        "postgresql.target"
        "mysql.service"
      ];

      before = [ "phpfpm-speedtest-tracker.service" ];
      partOf = [ "phpfpm-speedtest-tracker.service" ];
      requiredBy = [ "phpfpm-speedtest-tracker.service" ];
      restartTriggers = [ cfg.package ];

      serviceConfig = {
        ExecStart = speedtest-tracker-maintenance;
        RemainAfterExit = true;
      }
      // commonServiceConfig;

      unitConfig.JoinsNamespaceOf = "phpfpm-speedtest-tracker.service";
    };

    systemd.timers.speedtest-tracker-scheduler = {
      description = "Speedtest Tracker scheduler timer";
      restartTriggers = [ cfg.package ];

      timerConfig = {
        OnCalendar = "minutely";
        Persistent = true;
      };

      wantedBy = [ "timers.target" ];
    };

    systemd.tmpfiles.settings."10-speedtest-tracker" =
      lib.genAttrs
        [
          "${cfg.dataDir}/storage"
          "${cfg.dataDir}/storage/app"
          "${cfg.dataDir}/storage/database"
          "${cfg.dataDir}/storage/framework"
          "${cfg.dataDir}/storage/framework/cache"
          "${cfg.dataDir}/storage/framework/sessions"
          "${cfg.dataDir}/storage/framework/views"
          "${cfg.dataDir}/storage/logs"
          "${cfg.dataDir}/cache"
        ]
        (n: {
          d = {
            inherit group;
            inherit user;
            mode = "0700";
          };
        })
      // {
        "${cfg.dataDir}".d = {
          inherit group;
          inherit user;
          mode = "0710";
        };
      };

    users = {
      groups = lib.mkIf (group == defaultGroup) { ${defaultGroup} = { }; };

      users = lib.mkIf (user == defaultUser) {
        ${defaultUser} = {
          inherit group;
          home = cfg.dataDir;
          isSystemUser = true;
        };
      };
    };
  };

  meta.maintainers = pkgs.speedtest-tracker.meta.maintainers;
}
