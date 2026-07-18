{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  inherit (lib)
    getExe
    hasAttr
    mapAttrs
    match
    mkEnableOption
    mkIf
    mkPackageOption
    mkOption
    types
    optional
    optionalString
    escapeShellArg
    ;

  cfg = config.services.lasuite-docs;

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

  proxySuffix = if match "unix:.*" cfg.bind != null then ":" else "";

  commonServiceConfig = {
    # hardening
    AmbientCapabilities = "";
    CapabilityBoundingSet = [ "" ];
    DevicePolicy = "closed";
    DynamicUser = true;
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
    RemoveIPC = true;

    RestrictAddressFamilies = [
      "AF_INET"
      "AF_INET6"
      "AF_UNIX"
    ];

    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    RuntimeDirectory = "lasuite-docs";
    StateDirectory = "lasuite-docs";

    SupplementaryGroups = mkIf cfg.redis.createLocally [
      config.services.redis.servers.lasuite-docs.group
    ];

    SystemCallArchitectures = "native";
    UMask = "0077";
    User = "lasuite-docs";
    WorkingDirectory = "/var/lib/lasuite-docs";
  };

  # Convert environment variables to be used as systemd-run arguments
  envArgs = lib.concatStringsSep " " (
    lib.mapAttrsToList (name: value: "-E ${escapeShellArg "${name}=${value}"}") pythonEnvironment
  );

  # Easier usage of django manage.py stuff
  manage = pkgs.writeShellScriptBin "lasuite-docs-manage" ''
    exec ${lib.getExe' config.systemd.package "systemd-run"} \
      -p User=${commonServiceConfig.User} -p DynamicUser=yes \
      -p StateDirectory=${commonServiceConfig.StateDirectory} --working-directory=${commonServiceConfig.WorkingDirectory} \
      --quiet --collect --pipe --pty \
      ${envArgs} ${lib.getExe cfg.backendPackage} "$@"
  '';
in
{
  options.services.lasuite-docs = {
    enable = mkEnableOption "SuiteNumérique Docs";
    backendPackage = mkPackageOption pkgs "lasuite-docs" { };

    bind = mkOption {
      default = "unix:/run/lasuite-docs/gunicorn.sock";

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

    collaborationServer = {
      package = mkPackageOption pkgs "lasuite-docs-collaboration-server" { };

      port = mkOption {
        default = 4444;

        description = ''
          Port used by the collaboration server to listen.
        '';

        type = types.port;
      };

      settings = mkOption {
        default = { };

        description = ''
          Configuration options of collaboration server.

          See <https://github.com/suitenumerique/docs/blob/v${cfg.collaborationServer.package.version}/docs/env.md>
        '';

        example = ''
          {
            COLLABORATION_LOGGING = true;
          }
        '';

        type = types.submodule {
          options = {
            COLLABORATION_BACKEND_BASE_URL = mkOption {
              default = "https://${cfg.domain}";
              defaultText = lib.literalExpression "https://\${cfg.domain}";
              description = "URL to the backend server base";
              type = types.str;
            };

            COLLABORATION_SERVER_ORIGIN = mkOption {
              default = "https://${cfg.domain}";
              defaultText = lib.literalExpression "https://\${cfg.domain}";
              description = "Origins allowed to connect to the collaboration server";
              type = types.str;
            };

            PORT = mkOption {
              default = toString cfg.collaborationServer.port;
              description = "Port used by collaboration server to listen to";
              readOnly = true;
              type = types.str;
            };
          };

          freeformType = types.attrsOf (
            types.oneOf [
              types.str
              types.bool
            ]
          );
        };
      };
    };

    domain = mkOption {
      description = ''
        Domain name of the docs instance.
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

        This can be useful to pass secrets to docs via tools like `agenix` or `sops`.
      '';

      type = types.nullOr types.path;
    };

    frontendPackage = mkPackageOption pkgs "lasuite-docs-frontend" { };

    gunicorn = {
      extraArgs = mkOption {
        default = [
          "--name=impress"
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
          Configure local PostgreSQL database server for docs.
        '';

        type = types.bool;
      };
    };

    redis = {
      createLocally = mkOption {
        default = false;

        description = ''
          Configure local Redis cache server for docs.
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

        If not set, the secret key will be automatically generated.
      '';

      type = types.nullOr types.path;
    };

    settings = mkOption {
      default = { };

      description = ''
        Configuration options of docs.

        See <https://github.com/suitenumerique/docs/blob/v${cfg.backendPackage.version}/docs/env.md>

        `REDIS_URL` and `CELERY_BROKER_URL` are set if `services.lasuite-docs.redis.createLocally` is true.
        `DB_HOST` is set if `services.lasuite-docs.postgresql.createLocally` is true.
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
                "redis+socket://${config.services.redis.servers.lasuite-docs.unixSocket}?db=1"
              else
                null;

            description = "URL of the redis backend for celery";
            type = types.nullOr types.str;
          };

          DATA_DIR = mkOption {
            default = "/var/lib/lasuite-docs";
            description = "Path to the data directory";
            type = types.path;
          };

          DB_HOST = mkOption {
            default = if cfg.postgresql.createLocally then "/run/postgresql" else null;
            description = "Host of the database";
            type = types.nullOr types.str;
          };

          DB_NAME = mkOption {
            default = "lasuite-docs";
            description = "Name of the database";
            type = types.str;
          };

          DB_USER = mkOption {
            default = "lasuite-docs";
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

          DJANGO_SECRET_KEY_FILE = mkOption {
            default =
              if cfg.secretKeyPath == null then "/var/lib/lasuite-docs/django_secret_key" else cfg.secretKeyPath;

            description = "The path to the file containing Django's secret key";
            type = types.path;
          };

          DJANGO_SETTINGS_MODULE = mkOption {
            default = "impress.settings";
            description = "The configuration module that Django will use";
            internal = true;
            type = types.str;
          };

          REDIS_URL = mkOption {
            default =
              if cfg.redis.createLocally then
                "unix://${config.services.redis.servers.lasuite-docs.unixSocket}?db=0"
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
          error_page 401 /401;
          error_page 403 /403;
          error_page 404 /404;
        '';

        locations."/admin" = {
          proxyPass = "http://${cfg.bind}";
          recommendedProxySettings = true;
        };

        locations."/api" = {
          proxyPass = "http://${cfg.bind}";
          recommendedProxySettings = true;
        };

        locations."/collaboration/api/" = {
          proxyPass = "http://localhost:${toString cfg.collaborationServer.port}";
          recommendedProxySettings = true;
        };

        locations."/collaboration/ws/" = {
          proxyPass = "http://localhost:${toString cfg.collaborationServer.port}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };

        locations."/media-auth" = {
          extraConfig = ''
            proxy_set_header X-Original-URL $request_uri;
            proxy_pass_request_body off;
            proxy_set_header Content-Length "";
            proxy_set_header X-Original-Method $request_method;
          '';

          proxyPass = "http://${cfg.bind}${proxySuffix}/api/v1.0/documents/media-auth/";
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

            add_header Content-Security-Policy "default-src 'none'" always;
          '';

          proxyPass = cfg.s3Url;
        };

        locations."/static/" = {
          alias = "${cfg.backendPackage}/share/static/";
        };

        locations."~ '^/docs/[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}/?$'" = {
          tryFiles = "$uri /docs/[id]/index.html";
        };

        locations."~ '^/user-reconciliations/(active|inactive)/[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}/?$'" =
          {
            tryFiles = "$uri /user-reconciliations/$1/[id]/index.html";
          };

        root = cfg.frontendPackage;
      };
    };

    services.postgresql = mkIf cfg.postgresql.createLocally {
      enable = true;
      ensureDatabases = [ "lasuite-docs" ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = "lasuite-docs";
        }
      ];
    };

    services.redis.servers.lasuite-docs = mkIf cfg.redis.createLocally { enable = true; };

    systemd.services.lasuite-docs = {
      after = [
        "network.target"
      ]
      ++ (optional cfg.postgresql.createLocally "postgresql.target")
      ++ (optional cfg.redis.createLocally "redis-lasuite-docs.service");

      description = "Docs from SuiteNumérique";
      environment = pythonEnvironment;

      preStart = ''
        if [ ! -f .version ]; then
          touch .version
        fi

        ${optionalString (cfg.secretKeyPath == null) ''
          if [[ ! -f /var/lib/lasuite-docs/django_secret_key ]]; then
            (
              umask 0377
              tr -dc A-Za-z0-9 < /dev/urandom | head -c64 | ${pkgs.moreutils}/bin/sponge /var/lib/lasuite-docs/django_secret_key
            )
          fi
        ''}
        if [ "${cfg.backendPackage.version}" != "$(cat .version)" ]; then
          ${getExe cfg.backendPackage} migrate
          echo -n "${cfg.backendPackage.version}" > .version
        fi
      '';

      serviceConfig = {
        BindReadOnlyPaths = "${cfg.backendPackage}/share/static:/var/lib/lasuite-docs/static";
        EnvironmentFile = optional (cfg.environmentFile != null) cfg.environmentFile;

        ExecStart = utils.escapeSystemdExecArgs (
          [
            (lib.getExe' cfg.backendPackage "gunicorn")
            "--bind=${cfg.bind}"
          ]
          ++ cfg.gunicorn.extraArgs
          ++ [ "impress.wsgi:application" ]
        );

        MemoryDenyWriteExecute = true;
      }
      // commonServiceConfig;

      wantedBy = [ "multi-user.target" ];

      wants =
        (optional cfg.postgresql.createLocally "postgresql.target")
        ++ (optional cfg.redis.createLocally "redis-lasuite-docs.service");
    };

    systemd.services.lasuite-docs-celery = {
      after = [
        "network.target"
      ]
      ++ (optional cfg.postgresql.createLocally "postgresql.target")
      ++ (optional cfg.redis.createLocally "redis-lasuite-docs.service");

      description = "Docs Celery broker from SuiteNumérique";
      environment = pythonEnvironment;

      serviceConfig = {
        EnvironmentFile = optional (cfg.environmentFile != null) cfg.environmentFile;

        ExecStart = utils.escapeSystemdExecArgs (
          [
            (lib.getExe' cfg.backendPackage "celery")
          ]
          ++ cfg.celery.extraArgs
          ++ [
            "--app=impress.celery_app"
            "worker"
          ]
        );

        MemoryDenyWriteExecute = true;
      }
      // commonServiceConfig;

      wantedBy = [ "multi-user.target" ];

      wants =
        (optional cfg.postgresql.createLocally "postgresql.target")
        ++ (optional cfg.redis.createLocally "redis-lasuite-docs.service");
    };

    systemd.services.lasuite-docs-collaboration-server = {
      after = [ "network.target" ];
      description = "Docs Collaboration Server from SuiteNumérique";
      environment = cfg.collaborationServer.settings;

      serviceConfig = {
        ExecStart = getExe cfg.collaborationServer.package;
      }
      // commonServiceConfig;

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.lasuite-docs-postgresql-setup = mkIf cfg.postgresql.createLocally {
      after = [ "postgresql-setup.service" ];
      before = [ "lasuite-docs.service" ];
      requiredBy = [ "lasuite-docs.service" ];

      serviceConfig = {
        # hardening
        AmbientCapabilities = "";
        CapabilityBoundingSet = [ "" ];
        DevicePolicy = "closed";

        # lasuite-docs user cannot create a C function as it is unsafe.
        ExecStart = ''
          ${lib.getExe' config.services.postgresql.package "psql"} --port=${toString config.services.postgresql.settings.port} -d lasuite-docs -c "CREATE OR REPLACE FUNCTION public.immutable_unaccent(regdictionary, text) RETURNS text LANGUAGE c IMMUTABLE PARALLEL SAFE STRICT AS '$libdir/unaccent', 'unaccent_dict';"
        '';

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
        RemoveIPC = true;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        Slice = "system-lasuite-docs.slice";
        SystemCallArchitectures = "native";
        Type = "oneshot";
        UMask = "0077";
        User = "postgres";
      };

      wantedBy = [ "lasuite-docs.target" ];

    };

    # Some settings options in LaSuite has been renamed in 5.0.0
    # Show warnings if those settings are not renamed
    # TODO: remove it when the retrocompatibility options will be gone
    warnings =
      (optional (hasAttr "AI_API_KEY" cfg.settings) "AI_API_KEY has been renamed as OPENAI_SDK_API_KEY in LaSuite Docs")
      ++ (optional (hasAttr "AI_API_KEY_FILE" cfg.settings) "AI_API_KEY_FILE has been renamed as OPENAI_SDK_API_KEY_FILE in LaSuite Docs")
      ++ (optional (hasAttr "AI_BASE_URL" cfg.settings) "AI_BASE_URL has been renamed as OPENAI_SDK_BASE_URL in LaSuite Docs");
  };

  meta = {
    buildDocsInSandbox = false;
    maintainers = [ lib.maintainers.soyouzpanda ];
  };
}
