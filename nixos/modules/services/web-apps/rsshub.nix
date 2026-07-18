{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.rsshub;
in
{
  options.services.rsshub = {
    enable = lib.mkEnableOption "RSSHub service";
    package = lib.mkPackageOption pkgs "rsshub" { };

    openFirewall = lib.mkOption {
      default = false;
      description = "Whether to open the firewall for the specified port.";
      type = lib.types.bool;
    };

    redis = {
      enable = lib.mkEnableOption "Redis for RSSHub";

      createLocally = lib.mkOption {
        default = true;
        description = "Create and use a local Redis instance. Sets `services.redis.servers.rsshub`.";
        type = lib.types.bool;
      };

      host = lib.mkOption {
        default = "localhost";
        description = "The Redis host.";
        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 6379;
        description = "The Redis port.";
        type = lib.types.port;
      };
    };

    secretFiles = lib.mkOption {
      default = [ ];

      description = ''
        Environment variables stored in files for secrets.
        See <https://docs.rsshub.app/deploy/config> for available options.
      '';

      example = lib.literalExpression ''
        [ config.sops.secrets.rsshub.path ]
      '';

      type = lib.types.listOf lib.types.path;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Environment variables for RSSHub.
        See <https://docs.rsshub.app/deploy/config> for available options.
      '';

      example = lib.literalExpression ''
        {
          REQUEST_TIMEOUT = "3000";
          REQUEST_RETRY = "10";
          CHROMIUM_EXECUTABLE_PATH = lib.getExe pkgs.chromium;
        }
      '';

      type = lib.types.submodule {
        options = {
          LISTEN_INADDR_ANY = lib.mkOption {
            apply = x: if x then "1" else "0";
            default = false;
            description = "Listen to any address";
            type = lib.types.bool;
          };

          NO_LOGFILES = lib.mkOption {
            apply = x: if x then "1" else "0";
            default = true;
            description = "Print logs into stderr.";
            type = lib.types.bool;
          };

          PORT = lib.mkOption {
            apply = toString;
            default = 1200;
            description = "Listen on port.";
            type = lib.types.port;
          };
        };

        freeformType = lib.types.attrsOf lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ (lib.toInt cfg.settings.PORT) ];

    services.redis.servers.rsshub = lib.mkIf (cfg.redis.enable && cfg.redis.createLocally) {
      enable = true;
      port = cfg.redis.port;
    };

    services.rsshub.settings = lib.mkIf cfg.redis.enable {
      CACHE_TYPE = "redis";
      REDIS_URL = "redis://${cfg.redis.host}:${toString cfg.redis.port}";
    };

    systemd.services.rsshub = {
      after = lib.optional (cfg.redis.enable && cfg.redis.createLocally) "redis-rsshub.service";
      description = "RSSHub - Everything is RSSible";
      environment = cfg.settings;
      requires = lib.optional (cfg.redis.enable && cfg.redis.createLocally) "redis-rsshub.service";

      serviceConfig = {
        DynamicUser = true;
        EnvironmentFile = cfg.secretFiles;
        ExecStart = lib.getExe cfg.package;
        Group = "rsshub";
        # Hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        Restart = "on-failure";
        RestartSec = "10s";
        StateDirectory = "rsshub";
        Type = "simple";
        User = "rsshub";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ vonfry ];
}
