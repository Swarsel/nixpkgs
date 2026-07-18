{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.nextcloud.notify_push;
  cfgN = config.services.nextcloud;
in
{
  options.services.nextcloud.notify_push = {
    enable = lib.mkEnableOption "Notify push";
    package = lib.mkPackageOption pkgs "nextcloud-notify_push" { };

    bendDomainToLocalhost = lib.mkOption {
      default = false;

      description = ''
        Whether to add an entry to `/etc/hosts` for the configured nextcloud domain to point to `localhost` and add `localhost `to nextcloud's `trusted_proxies` config option.

        This is useful when nextcloud's domain is not a static IP address and when the reverse proxy cannot be bypassed because the backend connection is done via unix socket.
      '';

      type = lib.types.bool;
    };

    logLevel = lib.mkOption {
      default = "error";
      description = "Log level";

      type = lib.types.enum [
        "error"
        "warn"
        "info"
        "debug"
        "trace"
      ];
    };

    nextcloudUrl = lib.mkOption {
      default = "http${lib.optionalString cfgN.https "s"}://${cfgN.hostName}";
      defaultText = lib.literalExpression ''"http''${lib.optionalString config.services.nextcloud.https "s"}://''${config.services.nextcloud.hostName}"'';
      description = "Configure the nextcloud URL notify_push tries to connect to.";
      type = lib.types.str;
    };

    socketPath = lib.mkOption {
      default = "/run/nextcloud-notify_push/sock";
      description = "Socket path to use for notify_push";
      type = lib.types.str;
    };
  }
  // (lib.genAttrs
    [
      "dbtype"
      "dbname"
      "dbuser"
      "dbpassFile"
      "dbhost"
      "dbport"
      "dbtableprefix"
    ]
    (
      opt:
      options.services.nextcloud.config.${opt}
      // {
        default = config.services.nextcloud.config.${opt};
        defaultText = lib.literalExpression "config.services.nextcloud.config.${opt}";
      }
    )
  );

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.nextcloud.config.dbtype != "sqlite";
        message = "notify_push only supports Nextcloud's with either a Postgres or MariaDB database, not sqlite.";
      }
    ];

    networking.hosts = lib.mkIf cfg.bendDomainToLocalhost {
      "127.0.0.1" = [ cfgN.hostName ];
      "::1" = [ cfgN.hostName ];
    };

    services = {
      nextcloud = {
        extraApps = {
          inherit (config.services.nextcloud.package.packages.apps)
            notify_push
            ;
        };

        settings.trusted_proxies = lib.mkIf cfg.bendDomainToLocalhost [
          "127.0.0.1"
          "::1"
        ];
      };

      nginx.virtualHosts.${cfgN.hostName}.locations."^~ /push/" = {
        extraConfig = # nginx
          ''
            # disable in case it was configured on a higher level
            keepalive_timeout 0;
            proxy_buffering off;
          '';

        proxyPass = "http://unix:${cfg.socketPath}";
        proxyWebsockets = true;
        recommendedProxySettings = lib.mkDefault true;
      };
    };

    systemd.services = {
      nextcloud-notify_push = {
        after = [
          "nextcloud-setup.service"
          "phpfpm-nextcloud.service"
          "redis-nextcloud.service"
        ];

        description = "Push daemon for Nextcloud clients";
        documentation = [ "https://github.com/nextcloud/notify_push" ];

        environment = {
          DATABASE_PREFIX = cfg.dbtableprefix;
          LOG = cfg.logLevel;
          NEXTCLOUD_URL = cfg.nextcloudUrl;
          SOCKET_PATH = cfg.socketPath;
        };

        requires = [
          "nextcloud-setup.service"
          "phpfpm-nextcloud.service"
        ];

        script =
          let
            dbType = if cfg.dbtype == "pgsql" then "postgresql" else cfg.dbtype;
            dbUser = lib.optionalString (cfg.dbuser != null) cfg.dbuser;
            dbPass = lib.optionalString (cfg.dbpassFile != null) ":$DATABASE_PASSWORD";
            dbHostHasPrefix = prefix: lib.hasPrefix prefix (toString cfg.dbhost);
            isPostgresql = dbType == "postgresql";
            isMysql = dbType == "mysql";
            isSocket = (isPostgresql && dbHostHasPrefix "/") || (isMysql && dbHostHasPrefix "localhost:/");
            dbHost = lib.optionalString (cfg.dbhost != null) (
              if isSocket then lib.optionalString isMysql "@localhost" else "@${cfg.dbhost}"
            );
            dbOpts = lib.optionalString (cfg.dbhost != null && isSocket) (
              if isPostgresql then
                "?host=${cfg.dbhost}"
              else if isMysql then
                "?socket=${lib.removePrefix "localhost:" cfg.dbhost}"
              else
                throw "unsupported dbtype"
            );
            dbName = lib.optionalString (cfg.dbname != null) "/${cfg.dbname}";
            dbUrl = "${dbType}://${dbUser}${dbPass}${dbHost}${dbName}${dbOpts}";
          in
          lib.optionalString (cfg.dbpassFile != null) ''
            export DATABASE_PASSWORD="$(<"$CREDENTIALS_DIRECTORY/dbpass")"
          ''
          + ''
            export DATABASE_URL="${dbUrl}"
            exec ${cfg.package}/bin/notify_push '${cfgN.datadir}/config/config.php'
          '';

        serviceConfig = {
          Group = "nextcloud";
          LoadCredential = lib.optional (cfg.dbpassFile != null) "dbpass:${cfg.dbpassFile}";
          Restart = "on-failure";
          RestartSec = "5s";
          RuntimeDirectory = [ "nextcloud-notify_push" ];
          Type = "notify";
          User = "nextcloud";
        };

        wantedBy = [ "multi-user.target" ];
      };

      nextcloud-notify_push_setup = {
        after = [ "nextcloud-notify_push.service" ];
        requiredBy = [ "nextcloud-notify_push.service" ];

        serviceConfig = {
          ExecStart = "${lib.getExe cfgN.occ} notify_push:setup ${cfg.nextcloudUrl}/push";
          Group = "nextcloud";
          LoadCredential = config.systemd.services.nextcloud-cron.serviceConfig.LoadCredential;
          Restart = "on-failure";
          RestartMode = "direct";
          RestartSec = "5s";
          Type = "oneshot";
          User = "nextcloud";
        };

        unitConfig = {
          StartLimitBurst = 5;
          StartLimitIntervalSec = 30;
        };

        wantedBy = [ "multi-user.target" ];
      };
    };
  };
}
