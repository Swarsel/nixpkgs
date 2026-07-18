{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.glitchtip;
  pkg = cfg.package;
  inherit (pkg.passthru) python;

  environment = lib.mapAttrs (
    _: value:
    if value == true then
      "True"
    else if value == false then
      "False"
    else
      toString value
  ) cfg.settings;
in

{
  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "glitchtip" "listenAddress" ]
      [ "services" "glitchtip" "settings" "GRANIAN_HOST" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "glitchtip" "port" ]
      [ "services" "glitchtip" "settings" "GRANIAN_PORT" ]
    )
    (lib.mkRemovedOptionModule [ "services" "glitchtip" "celery" "extraArgs" ]
      "GlitchTip 6 migrated away from celery. Please check the upstream docs how to handle your usecase now."
    )
    (lib.mkRemovedOptionModule [ "services" "glitchtip" "gunicorn" "extraArgs" ]
      "GlitchTip 6 migrated away from gunicorn. Please check the upstream docs how to handle your usecase now."
    )
  ];

  options = {
    services.glitchtip = {
      enable = lib.mkEnableOption "GlitchTip";
      package = lib.mkPackageOption pkgs "glitchtip" { };

      database.createLocally = lib.mkOption {
        default = true;
        description = "Whether to enable and configure a local PostgreSQL database server.";
        type = lib.types.bool;
      };

      environmentFiles = lib.mkOption {
        default = [ ];

        description = ''
          Files to load environment variables from in addition to [](#opt-services.glitchtip.settings).
          This is useful to avoid putting secrets into the nix store.
          See <https://glitchtip.com/documentation/install#configuration> for more information.
        '';

        example = [ "/run/secrets/glitchtip.env" ];
        type = lib.types.listOf lib.types.path;
      };

      group = lib.mkOption {
        default = "glitchtip";
        description = "The group under which GlitchTip runs.";
        type = lib.types.str;
      };

      nginx = {
        createLocally = lib.mkOption {
          default = false;
          description = "Whether to enable and configure a local Nginx server.";
          type = lib.types.bool;
        };

        domain = lib.mkOption {
          description = ''
            Domain under which GlitchTip will be reachable.
            In contrast to `settings.GLITCHTIP_DOMAIN` this option has no protocol.
            It will also set `settings.GLITCHTIP_DOMAIN` with the `https://` protocol.
          '';

          example = "glitchtip.example.com";
          type = lib.types.str;
        };
      };

      redis.createLocally = lib.mkOption {
        default = true;
        description = "Whether to enable and configure a local Redis instance.";
        type = lib.types.bool;
      };

      settings = lib.mkOption {
        default = { };

        defaultText = lib.literalExpression ''
          {
            DEBUG = 0;
            DEBUG_TOOLBAR = 0;
            DATABASE_URL = lib.mkIf config.services.glitchtip.database.createLocally "postgresql://@/glitchtip";
            GLITCHTIP_DOMAIN = lib.mkIf config.services.glitchtip.nginx.createLocally "https://''${config.services.glitchtip.nginx.domain}";
            GLITCHTIP_VERSION = config.services.glitchtip.package.version;
            GRANIAN_HOST = "127.0.0.1";
            GRANIAN_PORT = 8000;
            GRANIAN_STATIC_PATH_MOUNT = "''${config.services.glitchtip.package}/lib/glitchtip/static";
            GRANIAN_WORKERS = 1;
            PYTHONUNBUFFERED = 1;
            REDIS_URL = lib.mkIf config.services.glitchtip.redis.createLocally "unix://''${config.services.redis.servers.glitchtip.unixSocket}";
          }
        '';

        description = ''
          Configuration of GlitchTip. See <https://glitchtip.com/documentation/install#configuration> for more information and required settings.
        '';

        example = {
          DATABASE_URL = "postgres://postgres:postgres@postgres/postgres";
          GLITCHTIP_DOMAIN = "https://glitchtip.example.com";
        };

        type = lib.types.submodule {
          options = {
            ENABLE_OBSERVABILITY_API = lib.mkOption {
              default = false;
              description = "Whether to enable the Prometheus metrics endpoint.";
              type = lib.types.bool;
            };

            ENABLE_ORGANIZATION_CREATION = lib.mkOption {
              default = false;

              description = ''
                When false, only superusers will be able to create new organizations after the first. When true, any user can create a new organization.
              '';

              type = lib.types.bool;
            };

            ENABLE_USER_REGISTRATION = lib.mkOption {
              default = false;

              description = ''
                When true, any user will be able to register. When false, user self-signup is disabled after the first user is registered. Subsequent users must be created by a superuser on the backend and organization invitations may only be sent to existing users.
              '';

              type = lib.types.bool;
            };

            GLITCHTIP_DOMAIN = lib.mkOption {
              default = null;
              description = "The URL under which GlitchTip is externally reachable.";
              example = "https://glitchtip.example.com";
              type = lib.types.nullOr lib.types.str;
            };

            GLITCHTIP_ENABLE_MCP = lib.mkOption {
              default = false;
              description = "Whether to enable the MCP api.";
              type = lib.types.bool;
            };

            GRANIAN_WORKERS = lib.mkOption {
              default = 1;
              description = "Number of granian workers to start";
              type = lib.types.ints.positive;
            };
          };

          freeformType =
            with lib.types;
            attrsOf (oneOf [
              str
              int
              bool
            ]);
        };
      };

      stateDir = lib.mkOption {
        default = "/var/lib/glitchtip";
        description = "State directory of glitchtip.";
        type = lib.types.path;
      };

      user = lib.mkOption {
        default = "glitchtip";
        description = "The user account under which GlitchTip runs.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "glitchtip-manage" ''
        set -o allexport
        ${lib.toShellVars environment}
        ${lib.concatMapStringsSep "\n" (f: "source ${f}") cfg.environmentFiles}
        ${config.security.wrapperDir}/sudo -E -u ${cfg.user} ${lib.getExe pkg} "$@"
      '')
    ];

    services.glitchtip.settings = {
      DEBUG = lib.mkDefault 0;
      DEBUG_TOOLBAR = lib.mkDefault 0;
      GLITCHTIP_VERSION = pkg.version;
      GRANIAN_HOST = lib.mkDefault "127.0.0.1";
      GRANIAN_PORT = lib.mkDefault 8000;
      GRANIAN_STATIC_PATH_MOUNT = "${pkg}/lib/glitchtip/static";
      GRANIAN_WORKERS = lib.mkDefault 1;
      PYTHONPATH = "${python.pkgs.makePythonPath pkg.propagatedBuildInputs}:${pkg}/lib/glitchtip";
      PYTHONUNBUFFERED = lib.mkDefault 1;
    }
    // lib.optionalAttrs cfg.database.createLocally { DATABASE_URL = "postgresql://@/glitchtip"; }
    // lib.optionalAttrs cfg.nginx.createLocally { GLITCHTIP_DOMAIN = "https://${cfg.nginx.domain}"; }
    // lib.optionalAttrs cfg.redis.createLocally {
      REDIS_URL = "unix://${config.services.redis.servers.glitchtip.unixSocket}";
    };

    services.nginx = lib.mkIf cfg.nginx.createLocally {
      enable = true;

      virtualHosts.${cfg.nginx.domain} = {
        forceSSL = lib.mkDefault true;

        locations = {
          "/".proxyPass = "http://${cfg.settings.GRANIAN_HOST}:${toString cfg.settings.GRANIAN_PORT}";
          "/static/".root = "${pkg}/lib/glitchtip";
        };
      };
    };

    services.postgresql = lib.mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ "glitchtip" ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = "glitchtip";
        }
      ];
    };

    services.redis.servers.glitchtip.enable = cfg.redis.createLocally;

    systemd.services =
      let
        commonService = {
          inherit environment;

          after = [
            "network-online.target"
          ]
          ++ lib.optional cfg.database.createLocally "postgresql.target"
          ++ lib.optional cfg.redis.createLocally "redis-glitchtip.service";

          requires =
            lib.optional cfg.database.createLocally "postgresql.target"
            ++ lib.optional cfg.redis.createLocally "redis-glitchtip.service";

          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
        };

        commonServiceConfig = {
          # hardening
          AmbientCapabilities = "";
          BindPaths = [ "${cfg.stateDir}/uploads:${pkg}/lib/glitchtip/uploads" ];
          CapabilityBoundingSet = [ "" ];
          DevicePolicy = "closed";
          EnvironmentFile = cfg.environmentFiles;
          Group = cfg.group;
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
          RestrictAddressFamilies = [ "AF_INET AF_INET6 AF_UNIX" ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RuntimeDirectory = "glitchtip";
          StateDirectory = "glitchtip";
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
            "~@resources"
            "@chown"
          ];

          UMask = "0077";
          User = cfg.user;
          WorkingDirectory = "${pkg}/lib/glitchtip";
        };
      in
      {
        glitchtip = commonService // {
          before = [ "glitchtip-worker.service" ];
          bindsTo = [ "glitchtip-worker.service" ];
          description = "GlitchTip";

          environment =
            environment
            // lib.optionalAttrs (cfg.settings.ENABLE_OBSERVABILITY_API && cfg.settings.WORKERS > 1) {
              PROMETHEUS_MULTIPROC_DIR = "/tmp/prometheus_multiproc";
            };

          preStart = ''
            ${lib.getExe pkg} migrate
            ${lib.getExe pkg} createcachetable
            ${lib.getExe pkg} maintain_partitions
          '';

          serviceConfig = commonServiceConfig // {
            ExecStart = ''
              ${lib.getExe python.pkgs.granian} \
                --interface ${if cfg.settings.GLITCHTIP_ENABLE_MCP then "asgi" else "asginl"} \
                glitchtip.asgi:application \
                --host ${cfg.settings.GRANIAN_HOST} \
                --port ${toString cfg.settings.GRANIAN_PORT} \
                --workers ${toString cfg.settings.GRANIAN_WORKERS} \
                --no-ws
            '';
          };
        };

        glitchtip-worker = commonService // {
          description = "GlitchTip Job Runner";

          environment = environment // {
            IS_WORKER = "1";
          };

          serviceConfig = commonServiceConfig // {
            ExecStart = "${lib.getExe pkg} runworker --scheduler";
          };
        };
      };

    systemd.tmpfiles.settings.glitchtip."${cfg.stateDir}/uploads".d = { inherit (cfg) user group; };
    users.groups = lib.mkIf (cfg.group == "glitchtip") { glitchtip = { }; };

    users.users = lib.mkIf (cfg.user == "glitchtip") {
      glitchtip = {
        extraGroups = lib.optionals cfg.redis.createLocally [ "redis-glitchtip" ];
        group = cfg.group;
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [
    defelo
    felbinger
  ];
}
