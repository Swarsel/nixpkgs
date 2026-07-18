{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  inherit (lib)
    concatMapStringsSep
    concatStringsSep
    escapeShellArg
    getExe
    hasSuffix
    mapAttrs
    match
    mkEnableOption
    mkIf
    mkPackageOption
    mkOption
    types
    optional
    optionalString
    ;

  cfg = config.services.lasuite-drive;

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

  commonServiceConfig = {
    # hardening
    AmbientCapabilities = "";
    CapabilityBoundingSet = [ "" ];
    DevicePolicy = "closed";
    DynamicUser = true;
    EnvironmentFile = cfg.environmentFiles;
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
    RuntimeDirectory = "lasuite-drive";
    StateDirectory = "lasuite-drive";

    SupplementaryGroups = mkIf cfg.redis.createLocally [
      config.services.redis.servers.lasuite-drive.group
    ];

    SystemCallArchitectures = "native";
    UMask = "0077";
    User = "lasuite-drive";
    WorkingDirectory = "/var/lib/lasuite-drive";
  };

  proxySuffix = if match "unix:.*" cfg.bind != null then ":" else "";

  # Convert environment variables to be used as systemd-run arguments
  envArgs = lib.concatStringsSep " " (
    lib.mapAttrsToList (name: value: "-E ${escapeShellArg "${name}=${value}"}") pythonEnvironment
  );

  # Easier usage of django manage.py stuff
  manage = pkgs.writeShellScriptBin "lasuite-drive-manage" ''
    exec ${lib.getExe' config.systemd.package "systemd-run"} \
      -p User=${commonServiceConfig.User} \
      -p DynamicUser=yes \
      -p StateDirectory=${commonServiceConfig.StateDirectory} \
      ${optionalString cfg.redis.createLocally "-p SupplementaryGroups=${config.services.redis.servers.lasuite-drive.group} \\"}
      ${concatMapStringsSep "\n" (envFile: "-p EnvironmentFile=${envFile} \\") cfg.environmentFiles}
      --working-directory=${commonServiceConfig.WorkingDirectory} \
      --quiet --collect --pipe --pty \
      ${envArgs} ${lib.getExe cfg.package} "$@"
  '';
in
{
  options.services.lasuite-drive = {
    enable = mkEnableOption "SuiteNumérique Drive";
    package = mkPackageOption pkgs "lasuite-drive" { };

    bind = mkOption {
      default = "unix:/run/lasuite-drive/gunicorn.sock";

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
        Domain name of the drive instance.
      '';

      type = types.str;
    };

    enableNginx = mkEnableOption "enable and configure Nginx for reverse proxying" // {
      default = true;
    };

    environmentFiles = mkOption {
      default = [ ];

      description = ''
        Path to environment files.

        This can be useful to pass secrets to drive via tools like `agenix` or `sops`.
      '';

      type = types.listOf types.path;
    };

    gunicorn = {
      extraArgs = mkOption {
        default = [
          "--name=drive"
          "--workers=3"
        ];

        description = ''
          Extra arguments to pass to the gunicorn process.
        '';

        type = types.listOf types.str;
      };
    };

    postgresql = {
      createLocally = mkOption {
        default = false;

        description = ''
          Configure local PostgreSQL database server for drive.
        '';

        type = types.bool;
      };
    };

    redis = {
      createLocally = mkOption {
        default = false;

        description = ''
          Configure local Redis cache server for drive.
        '';

        type = types.bool;
      };
    };

    s3Url = mkOption {
      description = ''
        URL of the S3 bucket.
      '';

      type = types.str;
    };

    secretKeyPath = mkOption {
      default = null;

      description = ''
        Path to the Django secret key.

        The key can be generated using:
        ```
        python3 -c 'import secrets; print(secrets.token_hex())'
        ```

        :::{.note}
        If not specified, a secret key is automatically generated and stored in the state directory.
        :::
      '';

      type = types.nullOr types.path;
    };

    settings = mkOption {
      default = { };

      description = ''
        Configuration options of drive.

        See <https://github.com/suitenumerique/drive/blob/v${cfg.package.version}/docs/env.md>

        `REDIS_URL` and `CELERY_BROKER_URL` are set if `services.lasuite-drive.redis.createLocally` is true.
        `DB_HOST` is set if `services.lasuite-drive.postgresql.createLocally` is true.
      '';

      example = ''
        {
          AWS_S3_ENDPOINT_URL = "https://s3.us-west.amazonaws.com";
        }
      '';

      type = types.submodule {
        options = {
          CELERY_BROKER_URL = mkOption {
            default =
              if cfg.redis.createLocally then
                "redis+socket://${config.services.redis.servers.lasuite-drive.unixSocket}?db=2"
              else
                null;

            description = "URL of the redis backend for celery";
            type = types.nullOr types.str;
          };

          DATA_DIR = mkOption {
            default = "/var/lib/lasuite-drive";
            description = "Path to the data directory";
            readOnly = true;
            type = types.path;
          };

          DB_HOST = mkOption {
            default = if cfg.postgresql.createLocally then "/run/postgresql" else null;
            description = "Host of the database";
            type = types.nullOr types.str;
          };

          DB_NAME = mkOption {
            default = "lasuite-drive";
            description = "Name of the database";
            type = types.str;
          };

          DB_USER = mkOption {
            default = "lasuite-drive";
            description = "User of the database";
            type = types.str;
          };

          DJANGO_ALLOWED_HOSTS = mkOption {
            apply = list: concatStringsSep "," list;

            default =
              if cfg.enableNginx then
                [
                  "localhost"
                  "127.0.0.1"
                  cfg.domain
                ]
              else
                [ ];

            defaultText = lib.literalExpression ''
              if cfg.enableNginx then [ "localhost" "127.0.0.1" cfg.domain ] else [ ]
            '';

            description = "Comma-separated list of hosts that are able to connect to the server";
            type = types.listOf types.str;
          };

          DJANGO_CONFIGURATION = mkOption {
            default = "Production";
            description = "The configuration that Django will use";
            internal = true;
            type = types.str;
          };

          DJANGO_SECRET_KEY_FILE = mkOption {
            default =
              if cfg.secretKeyPath == null then "/var/lib/lasuite-drive/django_secret_key" else cfg.secretKeyPath;

            description = "The path to the file containing Django's secret key";
            type = types.path;
          };

          DJANGO_SETTINGS_MODULE = mkOption {
            default = "drive.settings";
            description = "The configuration module that Django will use";
            internal = true;
            type = types.str;
          };

          REDIS_URL = mkOption {
            default =
              if cfg.redis.createLocally then
                "unix://${config.services.redis.servers.lasuite-drive.unixSocket}?db=1"
              else
                null;

            description = "URL of the redis backend";
            type = types.nullOr types.str;
          };
        };

        freeformType = types.attrsOf (
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
    environment.systemPackages = [ manage ];

    services.nginx = mkIf cfg.enableNginx {
      enable = true;

      virtualHosts.${cfg.domain} = {
        extraConfig = ''
          error_page 401 /401.html;
          error_page 403 /403.html;
          error_page 404 /404.html;
        '';

        locations."/" = {
          tryFiles = "$uri $uri.html index.html $uri/ =404";
        };

        locations."/admin" = {
          proxyPass = "http://${cfg.bind}";
          recommendedProxySettings = true;
        };

        locations."/api" = {
          proxyPass = "http://${cfg.bind}";
          recommendedProxySettings = true;
        };

        locations."/media-auth" = {
          extraConfig = ''
            proxy_set_header X-Original-URL $request_uri;
            proxy_pass_request_body off;
            proxy_set_header Content-Length "";
            proxy_set_header X-Original-Method $request_method;
          '';

          proxyPass = "http://${cfg.bind}${proxySuffix}/api/v1.0/items/media-auth/";
          recommendedProxySettings = true;
        };

        locations."/media/" = {
          extraConfig = ''
            auth_request /media-auth;
            auth_request_set $authHeader $upstream_http_authorization;
            auth_request_set $authDate $upstream_http_x_amz_date;
            auth_request_set $authContentSha256 $upstream_http_x_amz_content_sha256;

            proxy_set_header Authorization $authHeader;
            proxy_set_header X-Amz-Date $authDate;
            proxy_set_header X-Amz-Content-SHA256 $authContentSha256;

            add_header Content-Disposition "attachment";
          '';

          proxyPass = cfg.s3Url;
        };

        locations."/media/preview/" = {
          extraConfig = ''
            auth_request /media-auth;
            auth_request_set $authHeader $upstream_http_authorization;
            auth_request_set $authDate $upstream_http_x_amz_date;
            auth_request_set $authContentSha256 $upstream_http_x_amz_content_sha256;

            proxy_set_header Authorization $authHeader;
            proxy_set_header X-Amz-Date $authDate;
            proxy_set_header X-Amz-Content-SHA256 $authContentSha256;
          '';

          proxyPass = cfg.s3Url;
        };

        locations."/static/" = {
          alias = "${cfg.package}/share/static/";
        };

        locations."~ '^/explorer/items/[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}/?$'" =
          {
            tryFiles = "$uri /explorer/items/[id].html";
          };

        locations."~ '^/explorer/items/files/[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}/?$'" =
          {
            tryFiles = "$uri /explorer/items/files/[id].html";
          };

        locations."~ '^/wopi/[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}/?$'" = {
          tryFiles = "$uri /wopi/[id].html";
        };

        root = cfg.package.frontend;
      };
    };

    services.postgresql = mkIf cfg.postgresql.createLocally {
      enable = true;
      ensureDatabases = [ "lasuite-drive" ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = "lasuite-drive";
        }
      ];
    };

    services.redis.servers.lasuite-drive = mkIf cfg.redis.createLocally { enable = true; };

    systemd.services.lasuite-drive = {
      after = [
        "network-online.target"
      ]
      ++ (optional cfg.postgresql.createLocally "postgresql.service")
      ++ (optional cfg.redis.createLocally "redis-lasuite-drive.service");

      description = "Drive from SuiteNumérique";
      environment = pythonEnvironment;

      preStart = ''
        if [ ! -f .version ]; then
          touch .version
        fi

        ${optionalString (cfg.secretKeyPath == null) ''
          if [[ ! -f /var/lib/lasuite-drive/django_secret_key ]]; then
            (
              umask 0377
              tr -dc A-Za-z0-9 < /dev/urandom | head -c64 | ${pkgs.moreutils}/bin/sponge /var/lib/lasuite-drive/django_secret_key
            )
          fi
        ''}
        if [ "${cfg.package.version}" != "$(cat .version)" ]; then
          ${getExe cfg.package} migrate
          echo -n "${cfg.package.version}" > .version
        fi
      '';

      serviceConfig = {
        BindReadOnlyPaths = "${cfg.package}/share/static:/var/lib/lasuite-drive/static";

        ExecStart = utils.escapeSystemdExecArgs (
          [
            (lib.getExe' cfg.package "gunicorn")
            "--bind=${cfg.bind}"
          ]
          ++ cfg.gunicorn.extraArgs
          ++ [ "drive.wsgi:application" ]
        );
      }
      // commonServiceConfig;

      wantedBy = [ "multi-user.target" ];

      wants =
        (optional cfg.postgresql.createLocally "postgresql.service")
        ++ (optional cfg.redis.createLocally "redis-lasuite-drive.service");
    };

    systemd.services.lasuite-drive-beat = {
      after = [
        "network-online.target"
      ]
      ++ (optional cfg.postgresql.createLocally "postgresql.service")
      ++ (optional cfg.redis.createLocally "redis-lasuite-drive.service");

      description = "Docs Celery beat from SuiteNumérique";
      environment = pythonEnvironment;

      serviceConfig = {
        ExecStart = utils.escapeSystemdExecArgs (
          [ (lib.getExe' cfg.package "celery") ]
          ++ cfg.celery.extraArgs
          ++ [
            "--app=drive.celery_app"
            "beat"
          ]
        );
      }
      // commonServiceConfig;

      wantedBy = [ "multi-user.target" ];

      wants =
        (optional cfg.postgresql.createLocally "postgresql.service")
        ++ (optional cfg.redis.createLocally "redis-lasuite-drive.service");
    };

    systemd.services.lasuite-drive-celery = {
      after = [
        "network-online.target"
      ]
      ++ (optional cfg.postgresql.createLocally "postgresql.service")
      ++ (optional cfg.redis.createLocally "redis-lasuite-drive.service");

      description = "Docs Celery broker from SuiteNumérique";
      environment = pythonEnvironment;

      serviceConfig = {
        ExecStart = utils.escapeSystemdExecArgs (
          [ (lib.getExe' cfg.package "celery") ]
          ++ cfg.celery.extraArgs
          ++ [
            "--app=drive.celery_app"
            "worker"
          ]
        );
      }
      // commonServiceConfig;

      wantedBy = [ "multi-user.target" ];

      wants =
        (optional cfg.postgresql.createLocally "postgresql.service")
        ++ (optional cfg.redis.createLocally "redis-lasuite-drive.service");
    };

    warnings = mkIf (cfg.enableNginx && !(hasSuffix "/" cfg.s3Url)) [
      ''
        services.lasuite-drive.s3Url should end with a trailing slash (/).
        This could break the HTTP requests by nginx to the S3 backend.
      ''
    ];
  };

  meta = {
    buildDocsInSandbox = false;
    maintainers = [ lib.maintainers.soyouzpanda ];
  };
}
