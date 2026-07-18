{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  inherit (lib)
    elem
    getExe
    mapAttrs
    mkEnableOption
    mkIf
    mkMerge
    mkPackageOption
    mkOption
    mkRemovedOptionModule
    mkRenamedOptionModule
    types
    optional
    optionalString
    ;

  cfg = config.services.lasuite-meet;

  pythonEnvironment = mapAttrs (
    _: value:
    if value == null then
      "None"
    else if value == true then
      "True"
    else if value == false then
      "False"
    else
      toString value
  ) cfg.settings;

  commonSystemdConfig = {
    after = [
      "network.target"
    ]
    ++ (optional cfg.postgresql.createLocally "postgresql.service")
    ++ (optional cfg.redis.createLocally "redis-lasuite-meet.service");

    environment = pythonEnvironment;

    serviceConfig = {
      # hardening
      AmbientCapabilities = "";
      CapabilityBoundingSet = [ "" ];
      DevicePolicy = "closed";
      DynamicUser = true;
      EnvironmentFile = optional (cfg.environmentFile != null) cfg.environmentFile;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
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
      RemoveIPC = true;

      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];

      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      StateDirectory = "lasuite-meet";

      SupplementaryGroups = mkIf cfg.redis.createLocally [
        config.services.redis.servers.lasuite-meet.group
      ];

      SystemCallArchitectures = "native";
      UMask = "0077";
      User = "lasuite-meet";
      WorkingDirectory = "/var/lib/lasuite-meet";
    };

    wants =
      (optional cfg.postgresql.createLocally "postgresql.service")
      ++ (optional cfg.redis.createLocally "redis-lasuite-meet.service");
  };
in
{
  imports = [
    (mkRenamedOptionModule
      [ "services" "lasuite-meet" "backendPackage" ]
      [ "services" "lasuite-meet" "package" ]
    )
    (mkRemovedOptionModule [
      "services"
      "lasuite-meet"
      "frontendPackage"
    ] "services.lasuite-mette.package.frotend should be used instead")
  ];

  options.services.lasuite-meet = {
    enable = mkEnableOption "SuiteNumérique Meet";
    package = mkPackageOption pkgs "lasuite-meet" { };

    addons = mkOption {
      default = [ ];
      description = "Addons to use and configure";

      example = ''
        [
          "outlook"
        ]
      '';

      type = types.listOf (
        types.enum [
          "outlook"
        ]
      );
    };

    bind = mkOption {
      default = "unix:/run/lasuite-meet/gunicorn.sock";

      description = ''
        The path, host/port or file descriptior to bind the gunicorn socket to.

        See  <https://docs.gunicorn.org/en/stable/settings.html#bind> for possible options.
      '';

      example = "127.0.0.1:8000";
      type = types.str;
    };

    celery = {
      extraArgs = mkOption {
        default = [ ];

        description = ''
          Extra arguments to pass to the celery process.
        '';

        type = types.listOf types.str;
      };
    };

    domain = mkOption {
      description = ''
        Domain name of the meet instance.
      '';

      type = types.str;
    };

    enableNginx = mkEnableOption "enable and configure Nginx for reverse proxying" // {
      default = true;
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        Path to environment file.

        This can be useful to pass secrets to meet via tools like `agenix` or `sops`.
      '';

      type = types.nullOr types.path;
    };

    gunicorn = {
      extraArgs = mkOption {
        default = [
          "--name=meet"
          "--workers=3"
        ];

        description = ''
          Extra arguments to pass to the gunicorn process.
        '';

        type = types.listOf types.str;
      };
    };

    livekit = {
      enable = mkEnableOption "Configure local livekit server" // {
        default = true;
      };

      keyFile = mkOption {
        description = ''
          LiveKit key file holding one or multiple application secrets.
          Use `livekit-server generate-keys` to generate a random key name and secret.

          The file should have the YAML format `<keyname>: <secret>`.
          Example:
          `lasuite-meet: f6lQGaHtM5HfgZjIcec3cOCRfiDqIine4CpZZnqdT5cE`

          Individual key/secret pairs need to be passed to clients to connect to this instance.
        '';

        type = lib.types.path;

      };

      openFirewall = mkEnableOption "Open firewall ports for livekit";

      settings = mkOption {
        default = { };

        description = ''
          Settings to pass to the livekit server.

          See `services.livekit.settings` for more details.
        '';

        type = types.attrs;
      };
    };

    postgresql = {
      createLocally = mkEnableOption "Configure local PostgreSQL database server for meet";
    };

    redis = {
      createLocally = mkEnableOption "Configure local Redis cache server for meet";
    };

    secretKeyPath = mkOption {
      default = null;

      description = ''
        Path to the Django secret key.

        The key can be generated using:
        ```
        python3 -c 'import secrets; print(secrets.token_hex())'
        ```

        If not set, the secret key will be automatically generated.
      '';

      type = types.nullOr types.path;
    };

    settings = mkOption {
      default = { };

      description = ''
        Configuration options of meet.
        See https://github.com/suitenumerique/meet/blob/v${cfg.package.version}/docs/env.md
        `REDIS_URL` and `CELERY_BROKER_URL` are set if `services.lasuite-meet.redis.createLocally` is true.
        `DB_NAME` `DB_USER` and `DB_HOST` are set if `services.lasuite-meet.postgresql.createLocally` is true.
      '';

      example = ''
        {
          DJANGO_ALLOWED_HOSTS = "*";
        }
      '';

      type = types.submodule {
        options = {
          CELERY_BROKER_URL = mkOption {
            default =
              if cfg.redis.createLocally then
                "redis+socket://${config.services.redis.servers.lasuite-meet.unixSocket}?db=1"
              else
                null;

            description = "URL of the redis backend for celery";
            type = types.nullOr types.str;
          };

          DB_HOST = mkOption {
            default = if cfg.postgresql.createLocally then "/run/postgresql" else null;
            description = "Host of the database";
            type = types.nullOr types.str;
          };

          DB_NAME = mkOption {
            default = "lasuite-meet";
            description = "Name of the database";
            type = types.str;
          };

          DB_USER = mkOption {
            default = "lasuite-meet";
            description = "User of the database";
            type = types.str;
          };

          DJANGO_ALLOWED_HOSTS = mkOption {
            default = if cfg.enableNginx then "localhost,127.0.0.1,${cfg.domain}" else "";

            defaultText = lib.literalExpression ''
              if cfg.enableNginx then "localhost,127.0.0.1,''${cfg.domain}" else ""
            '';

            description = "Comma-separated list of hosts that are able to connect to the server";
            type = types.str;
          };

          DJANGO_CONFIGURATION = mkOption {
            default = "Production";
            description = "The configuration that Django will use";
            internal = true;
            type = types.str;
          };

          DJANGO_DATA_DIR = mkOption {
            default = "/var/lib/lasuite-meet";
            description = "Path to the data directory";
            type = types.path;
          };

          DJANGO_SECRET_KEY_FILE = mkOption {
            default =
              if cfg.secretKeyPath == null then "/var/lib/lasuite-meet/django_secret_key" else cfg.secretKeyPath;

            description = "The path to the file containing Django's secret key";
            type = types.path;
          };

          DJANGO_SETTINGS_MODULE = mkOption {
            default = "meet.settings";
            description = "The configuration module that Django will use";
            internal = true;
            type = types.str;
          };

          LIVEKIT_API_URL = mkOption {
            default = if cfg.enableNginx && cfg.livekit.enable then "http://${cfg.domain}/livekit" else null;

            defaultText = lib.literalExpression ''
              if cfg.enableNginx && cfg.livekit.enable then
                "http://$${cfg.domain}/livekit"
              else
                null
            '';

            description = "URL to the livekit server";
            type = types.nullOr types.str;
          };

          REDIS_URL = mkOption {
            default =
              if cfg.redis.createLocally then
                "unix://${config.services.redis.servers.lasuite-meet.unixSocket}?db=0"
              else
                null;

            description = "URL of the redis backend";
            type = types.nullOr types.str;
          };
        };

        freeformType = types.lazyAttrsOf (
          types.nullOr (
            types.oneOf [
              types.str
              types.bool
              types.path
              types.int
            ]
          )
        );
      };
    };
  };

  config = mkIf cfg.enable {
    services.livekit = mkIf cfg.livekit.enable {
      inherit (cfg.livekit)
        enable
        settings
        keyFile
        openFirewall
        ;
    };

    services.nginx = mkIf cfg.enableNginx {
      enable = true;

      virtualHosts.${cfg.domain} = mkMerge [
        {
          extraConfig = ''
            error_page 404 = /index.html;
          '';

          locations."/admin" = {
            proxyPass = "http://${cfg.bind}";
            recommendedProxySettings = true;
          };

          locations."/api" = {
            proxyPass = "http://${cfg.bind}";
            recommendedProxySettings = true;
          };

          locations."/static" = {
            root = "${cfg.package}/share";
          };

          root = cfg.package.frontend;
        }
        (mkIf cfg.livekit.enable {
          locations."/livekit" = {
            extraConfig = ''
              rewrite ^/livekit/(.*)$ /$1 break;
            '';

            proxyPass = "http://localhost:${toString config.services.livekit.settings.port}";
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };
        })
        (mkIf (elem "outlook" cfg.addons) {
          locations."/addons/outlook/" = {
            alias = "${cfg.package.addons.outlook}/";

            extraConfig = ''
              error_page 404 =200 /index.html;
              add_header Cache-Control "no-cache, no-store, must-revalidate";
              add_header Pragma "no-cache" always;
              add_header Expires 0 always;

              set $ms_domains "https://*.live.com https://*.office.com https://*.microsoft.com https://*.office365.com https://*.sharepoint.com";

              set $nonce $request_id;

              set $csp "upgrade-insecure-requests; ";
              set $csp "''${csp}frame-ancestors ''${ms_domains}; ";
              set $csp "''${csp}script-src 'nonce-''${nonce}' 'strict-dynamic'; ";
              set $csp "''${csp}connect-src 'self' ''${ms_domains}; ";
              set $csp "''${csp}frame-src 'none'; ";
              set $csp "''${csp}object-src 'none'; ";
              set $csp "''${csp}base-uri 'none'; ";

              add_header Content-Security-Policy $csp;

              sub_filter 'NONCE_PLACEHOLDER' $nonce;
              sub_filter_once off;
            '';
          };

          locations."= /.well-known/windows-app-web-link" = {
            alias = pkgs.writeText "lasuite-meet-winsows-app-web-link.json" ''
              [{
                "packageFamilyName" : "Visio_g3z6ba6vek6vg",
                "paths" : [ "*" ]
              }]
            '';

            extraConfig = ''
              default_type application/json;
              add_header Content-Disposition "attachment; filename=windows-app-web-link";
            '';
          };

          locations."= /addons/outlook/manifest.xml" = {
            alias = pkgs.stdenv.mkDerivation {
              buildCommand = ''
                substitute ${cfg.package.addons.outlook}/manifest.xml $out \
                  --replace-fail "__APP_NAME__" "LaSuite Meet" \
                  --replace-fail "https://localhost:3000/" "https://${cfg.domain}/addons/outlook/"
              '';

              name = "lasuite-meet-manifest.xml";
            };

            extraConfig = ''
              add_header Access-Control-Allow-Origin "*";
              add_header Cache-Control "no-cache, no-store, must-revalidate";
              add_header X-Frame-Options "DENY";
              add_header Content-Security-Policy "frame-ancestors 'none'";
            '';
          };
        })
      ];
    };

    services.postgresql = mkIf cfg.postgresql.createLocally {
      enable = true;
      ensureDatabases = [ "lasuite-meet" ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = "lasuite-meet";
        }
      ];
    };

    services.redis.servers.lasuite-meet = mkIf cfg.redis.createLocally { enable = true; };

    systemd.services.lasuite-meet = lib.mkMerge [
      {
        description = "Meet from SuiteNumérique";

        preStart = ''
          if [ ! -f .version ]; then
            touch .version
          fi

          ${optionalString (cfg.secretKeyPath == null) ''
            if [[ ! -f /var/lib/lasuite-meet/django_secret_key ]]; then
              (
                umask 0377
                tr -dc A-Za-z0-9 < /dev/urandom | head -c64 | ${pkgs.moreutils}/bin/sponge /var/lib/lasuite-meet/django_secret_key
              )
            fi
          ''}
          if [ "${cfg.package.version}" != "$(cat .version)" ]; then
            ${getExe cfg.package} migrate
            echo -n "${cfg.package.version}" > .version
          fi
        '';

        serviceConfig = {
          BindReadOnlyPaths = "${cfg.package}/share/static:/var/lib/lasuite-meet/static";

          ExecStart = utils.escapeSystemdExecArgs (
            [
              (lib.getExe' cfg.package "gunicorn")
              "--bind=${cfg.bind}"
            ]
            ++ cfg.gunicorn.extraArgs
            ++ [ "meet.wsgi:application" ]
          );

          # needs to be here so that cronjobs don't nuke it
          RuntimeDirectory = "lasuite-meet";
        };

        wantedBy = [ "multi-user.target" ];
      }
      commonSystemdConfig
    ];

    systemd.services.lasuite-meet-celery = lib.mkMerge [
      {
        description = "Meet Celery broker from SuiteNumérique";

        serviceConfig.ExecStart = utils.escapeSystemdExecArgs (
          [ (lib.getExe' cfg.package "celery") ]
          ++ cfg.celery.extraArgs
          ++ [
            "--app=meet.celery_app"
            "worker"
          ]
        );

        wantedBy = [ "multi-user.target" ];
      }
      commonSystemdConfig
    ];

    systemd.services.lasuite-meet-clean-pending-files = lib.mkMerge [
      {
        description = "Scheduled job to clean up pending uploads from LaSuite Meet";
        serviceConfig.ExecStart = "${getExe cfg.package} clean_pending_files";
        startAt = "daily";
      }
      commonSystemdConfig
    ];

    systemd.services.lasuite-meet-purge-deleted-files = lib.mkMerge [
      {
        description = "Scheduled job to purge deleted files from LaSuite Meet";
        serviceConfig.ExecStart = "${getExe cfg.package} purge_deleted_files";
        startAt = "daily";
      }
      commonSystemdConfig
    ];
  };

  meta = {
    buildDocsInSandbox = false;
    maintainers = [ lib.maintainers.soyouzpanda ];
  };
}
