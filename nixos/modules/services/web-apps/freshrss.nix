{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.freshrss;
  webserver = config.services.${cfg.webserver};

  extension-env = pkgs.buildEnv {
    name = "freshrss-extensions";
    paths = cfg.extensions;
  };
  env-vars = {
    DATA_PATH = cfg.dataDir;
  }
  // lib.optionalAttrs (cfg.extensions != [ ]) {
    THIRDPARTY_EXTENSIONS_PATH = "${extension-env}/share/freshrss";
  };
in
{
  options.services.freshrss = {
    enable = mkEnableOption "FreshRSS RSS aggregator and reader with php-fpm backend";
    package = mkPackageOption pkgs "freshrss" { };
    api.enable = mkEnableOption "API access for mobile apps and third-party clients (Google Reader API and Fever API). Users must set individual API passwords in their profile settings";

    authType = mkOption {
      default = "form";
      description = "Authentication type for FreshRSS.";

      type = types.enum [
        "form"
        "http_auth"
        "none"
      ];
    };

    baseUrl = mkOption {
      description = "Default URL for FreshRSS.";
      example = "https://freshrss.example.com";
      type = types.str;
    };

    dataDir = mkOption {
      default = "/var/lib/freshrss";
      description = "Default data folder for FreshRSS.";
      example = "/mnt/freshrss";
      type = types.str;
    };

    database = {
      host = mkOption {
        default = "localhost";
        description = "Database host for FreshRSS.";
        type = types.nullOr types.str;
      };

      name = mkOption {
        default = "freshrss";
        description = "Database name for FreshRSS.";
        type = types.nullOr types.str;
      };

      passFile = mkOption {
        default = null;
        description = "Database password file for FreshRSS.";
        example = "/run/secrets/freshrss";
        type = types.nullOr types.path;
      };

      port = mkOption {
        default = null;
        description = "Database port for FreshRSS.";
        example = 3306;
        type = types.nullOr types.port;
      };

      tableprefix = mkOption {
        default = null;
        description = "Database table prefix for FreshRSS.";
        example = "freshrss";
        type = types.nullOr types.str;
      };

      type = mkOption {
        default = "sqlite";
        description = "Database type.";
        example = "pgsql";

        type = types.enum [
          "sqlite"
          "pgsql"
          "mysql"
        ];
      };

      user = mkOption {
        default = "freshrss";
        description = "Database user for FreshRSS.";
        type = types.nullOr types.str;
      };
    };

    defaultUser = mkOption {
      default = "admin";
      description = "Default username for FreshRSS.";
      example = "eva";
      type = types.str;
    };

    extensions = mkOption {
      default = [ ];
      defaultText = literalExpression "[]";
      description = "Additional extensions to be used.";

      example = literalExpression ''
        with freshrss-extensions; [
          youtube
        ] ++ [
          (freshrss-extensions.buildFreshRssExtension {
            FreshRssExtUniqueId = "ReadingTime";
            pname = "reading-time";
            version = "1.5";
            src = pkgs.fetchFromGitLab {
              domain = "framagit.org";
              owner = "Lapineige";
              repo = "FreshRSS_Extension-ReadingTime";
              rev = "fb6e9e944ef6c5299fa56ffddbe04c41e5a34ebf";
             hash = "sha256-C5cRfaphx4Qz2xg2z+v5qRji8WVSIpvzMbethTdSqsk=";
           };
          })
        ]
      '';

      type = types.listOf types.package;
    };

    language = mkOption {
      default = "en";
      description = "Default language for FreshRSS.";
      example = "de";
      type = types.str;
    };

    passwordFile = mkOption {
      default = null;
      description = "Password for the defaultUser for FreshRSS.";
      example = "/run/secrets/freshrss";
      type = types.nullOr types.path;
    };

    pool = mkOption {
      default = "freshrss";

      description = ''
        Name of the php-fpm pool to use and setup. If not specified, a pool will be created
        with default values.
      '';

      type = types.nullOr types.str;
    };

    user = mkOption {
      default = "freshrss";
      description = "User under which FreshRSS runs.";
      type = types.str;
    };

    virtualHost = mkOption {
      default = "freshrss";

      description = ''
        Name of the caddy/nginx virtualhost to use and setup.
      '';

      type = types.str;
    };

    webserver = mkOption {
      default = "nginx";

      description = ''
        Whether to use nginx or caddy for virtual host management.

        Further nginx configuration can be done by adapting `services.nginx.virtualHosts.<name>`.
        See [](#opt-services.nginx.virtualHosts) for further information.

        Further caddy configuration can be done by adapting `services.caddy.virtualHosts.<name>`.
        See [](#opt-services.caddy.virtualHosts) for further information.
      '';

      type = types.enum [
        "nginx"
        "caddy"
      ];
    };
  };

  config =
    let
      defaultServiceConfig = {
        DeviceAllow = "";
        Group = config.users.users.${cfg.user}.group;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
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
        ReadWritePaths = "${cfg.dataDir}";
        RemoveIPC = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "freshrss";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@resources"
          "~@privileged"
        ];

        Type = "oneshot";
        UMask = "0007";
        User = cfg.user;
        WorkingDirectory = cfg.package;
      };
    in
    mkIf cfg.enable {
      assertions = mkIf (cfg.authType == "form") [
        {
          assertion = cfg.passwordFile != null;

          message = ''
            `passwordFile` must be supplied when using "form" authentication!
          '';
        }
      ];

      # Set up a Caddy virtual host.
      services.caddy = mkIf (cfg.webserver == "caddy") {
        enable = true;

        virtualHosts.${cfg.virtualHost}.extraConfig = ''
          root * ${config.services.freshrss.package}/p
          php_fastcgi unix/${config.services.phpfpm.pools.freshrss.socket} {
            env FRESHRSS_DATA_PATH ${config.services.freshrss.dataDir}
          }
          file_server
        '';
      };

      # Set up a Nginx virtual host.
      services.nginx = mkIf (cfg.webserver == "nginx") {
        enable = true;

        virtualHosts.${cfg.virtualHost} = {
          locations."/" = {
            index = "index.php index.html index.htm";
            tryFiles = "$uri $uri/ index.php";
          };

          # php files handling
          # this regex is mandatory because of the API
          locations."~ ^.+?\\.php(/.*)?$".extraConfig = ''
            fastcgi_pass unix:${config.services.phpfpm.pools.${cfg.pool}.socket};
            fastcgi_split_path_info ^(.+\.php)(/.*)$;
            # By default, the variable PATH_INFO is not set under PHP-FPM
            # But FreshRSS API greader.php need it. If you have a “Bad Request” error, double check this var!
            # NOTE: the separate $path_info variable is required. For more details, see:
            # https://trac.nginx.org/nginx/ticket/321
            set $path_info $fastcgi_path_info;
            fastcgi_param PATH_INFO $path_info;
            include ${pkgs.nginx}/conf/fastcgi_params;
            include ${pkgs.nginx}/conf/fastcgi.conf;
          '';

          root = "${cfg.package}/p";
        };
      };

      # Set up phpfpm pool
      services.phpfpm.pools = mkIf (cfg.pool != null) {
        ${cfg.pool} = {
          phpEnv = env-vars;

          settings = {
            "catch_workers_output" = true;
            "listen.group" = webserver.group;
            "listen.mode" = "0600";
            "listen.owner" = webserver.user;
            "pm" = "dynamic";
            "pm.max_children" = 32;
            "pm.max_requests" = 500;
            "pm.max_spare_servers" = 5;
            "pm.min_spare_servers" = 2;
            "pm.start_servers" = 2;
          };

          user = "freshrss";
        };
      };

      systemd.services.freshrss-config =
        let
          settingsFlags = concatStringsSep " \\\n    " (
            mapAttrsToList (k: v: "${k} ${toString v}") {
              ${if cfg.api.enable then "--api-enabled" else null} = "";

              # hostname:port e.g. "localhost:5432"
              ${if cfg.database.host != null && cfg.database.port != null then "--db-host" else null} =
                ''"${cfg.database.host}:${toString cfg.database.port}"'';

              # socket path e.g. "/run/postgresql"
              ${if cfg.database.host != null && cfg.database.port == null then "--db-host" else null} =
                ''"${cfg.database.host}"'';

              # The following attributes are optional depending on the type of
              # database.  Those that evaluate to null on the left hand side
              # will be omitted.
              ${if cfg.database.name != null then "--db-base" else null} = ''"${cfg.database.name}"'';

              ${if cfg.database.passFile != null then "--db-password" else null} =
                ''"$(cat ${cfg.database.passFile})"'';

              ${if cfg.database.tableprefix != null then "--db-prefix" else null} =
                ''"${cfg.database.tableprefix}"'';

              ${if cfg.database.user != null then "--db-user" else null} = ''"${cfg.database.user}"'';
              "--auth-type" = ''"${cfg.authType}"'';
              "--base-url" = ''"${cfg.baseUrl}"'';
              "--db-type" = ''"${cfg.database.type}"'';
              "--default-user" = ''"${cfg.defaultUser}"'';
              "--language" = ''"${cfg.language}"'';
            }
          );
        in
        {
          description = "Set up the state directory for FreshRSS before use";
          environment = env-vars;
          restartIfChanged = true;

          script =
            let
              isUserAuth = cfg.authType == "form" || cfg.authType == "none";

              userScriptArgs = "--user ${cfg.defaultUser} ${
                optionalString (cfg.authType == "form") ''--password "$(cat ${cfg.passwordFile})"''
              }";
              mkUserScript = name: optionalString isUserAuth "./cli/${name}.php ${userScriptArgs}";

              updateUserScript = mkUserScript "update-user";
              createUserScript = mkUserScript "create-user";
            in
            ''
              # do installation or reconfigure
              if test -f ${cfg.dataDir}/config.php; then
                # reconfigure with settings
                ./cli/reconfigure.php ${settingsFlags}
                ${updateUserScript}
              else
                # check correct folders in data folder
                ./cli/prepare.php
                # install with settings
                ./cli/do-install.php ${settingsFlags}
                ${createUserScript}
              fi
            '';

          serviceConfig = defaultServiceConfig // {
            RemainAfterExit = true;
          };

          wantedBy = [ "multi-user.target" ];
        };

      systemd.services.freshrss-updater = {
        after = [ "freshrss-config.service" ];
        description = "FreshRSS feed updater";
        environment = env-vars;

        serviceConfig = defaultServiceConfig // {
          ExecStart = "${cfg.package}/app/actualize_script.php";
        };

        startAt = "*:0/5";
      };

      systemd.tmpfiles.settings."10-freshrss".${cfg.dataDir}.d = {
        inherit (cfg) user;
        group = config.users.users.${cfg.user}.group;
      };

      users.groups."${cfg.user}" = { };

      users.users."${cfg.user}" = {
        description = "FreshRSS service user";
        group = "${cfg.user}";
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };

  meta.maintainers = with maintainers; [
    stunkymonkey
    mattchrist
  ];
}
