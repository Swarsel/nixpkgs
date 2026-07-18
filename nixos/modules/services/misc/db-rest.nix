{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    mkIf
    mkMerge
    mkDefault
    mkEnableOption
    mkPackageOption
    maintainers
    ;
  cfg = config.services.db-rest;
in
{
  options = {
    services.db-rest = {
      enable = mkEnableOption "db-rest service";
      package = mkPackageOption pkgs "db-rest" { };

      group = mkOption {
        default = "db-rest";
        description = "Group under which db-rest runs.";
        type = types.str;
      };

      host = mkOption {
        default = "127.0.0.1";
        description = "The host address the db-rest server should listen on.";
        type = types.str;
      };

      port = mkOption {
        default = 3000;
        description = "The port the db-rest server should listen on.";
        type = types.port;
      };

      redis = {
        enable = mkOption {
          default = false;
          description = "Enable caching with redis for db-rest.";
          type = types.bool;
        };

        createLocally = mkOption {
          default = true;
          description = "Configure a local redis server for db-rest.";
          type = types.bool;
        };

        host = mkOption {
          default = null;
          description = "Redis host.";
          type = with types; nullOr str;
        };

        passwordFile = mkOption {
          default = null;
          description = "Path to a file containing the redis password.";
          example = "/run/keys/db-rest/pasword-redis-db";
          type = with types; nullOr path;
        };

        port = mkOption {
          default = null;
          description = "Redis port.";
          type = with types; nullOr port;
        };

        useSSL = mkOption {
          default = true;
          description = "Use SSL if using a redis network connection.";
          type = types.bool;
        };

        user = mkOption {
          default = null;
          description = "Optional username used for authentication with redis.";
          type = with types; nullOr str;
        };
      };

      user = mkOption {
        default = "db-rest";
        description = "User account under which db-rest runs.";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion =
          (cfg.redis.enable && !cfg.redis.createLocally)
          -> (cfg.redis.host != null && cfg.redis.port != null);

        message = ''
          {option}`services.db-rest.redis.createLocally` and redis network connection ({option}`services.db-rest.redis.host` or {option}`services.db-rest.redis.port`) enabled. Disable either of them.
        '';
      }
      {
        assertion = (cfg.redis.enable && !cfg.redis.createLocally) -> (cfg.redis.passwordFile != null);

        message = ''
          {option}`services.db-rest.redis.createLocally` is disabled, but {option}`services.db-rest.redis.passwordFile` is not set.
        '';
      }
    ];

    services.redis.servers.db-rest.enable = cfg.redis.enable && cfg.redis.createLocally;

    systemd.services.db-rest = mkMerge [
      {
        after = [ "network.target" ] ++ lib.optional cfg.redis.createLocally "redis-db-rest.service";
        description = "db-rest service";

        environment = {
          HOSTNAME = cfg.host;
          NODE_ENV = "production";
          NODE_EXTRA_CA_CERTS = config.security.pki.caBundle;
          PORT = toString cfg.port;
        };

        requires = lib.optional cfg.redis.createLocally "redis-db-rest.service";

        serviceConfig = {
          CapabilityBoundingSet = "";
          ExecStart = mkDefault "${cfg.package}/bin/db-rest";
          Group = cfg.group;

          LoadCredential = lib.optional (
            cfg.redis.enable && cfg.redis.passwordFile != null
          ) "REDIS_PASSWORD:${cfg.redis.passwordFile}";

          LockPersonality = true;
          MemoryDenyWriteExecute = false;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
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
          Restart = "always";
          RestartSec = 5;

          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          Type = "simple";
          User = cfg.user;
          WorkingDirectory = cfg.package;
        };

        wantedBy = [ "multi-user.target" ];
      }
      (mkIf cfg.redis.enable (
        if cfg.redis.createLocally then
          { environment.REDIS_URL = config.services.redis.servers.db-rest.unixSocket; }
        else
          {
            script =
              let
                username = lib.optionalString (cfg.redis.user != null) (cfg.redis.user);
                host = cfg.redis.host;
                port = toString cfg.redis.port;
                protocol = if cfg.redis.useSSL then "rediss" else "redis";
              in
              ''
                export REDIS_URL="${protocol}://${username}:$(${config.systemd.package}/bin/systemd-creds cat REDIS_PASSWORD)@${host}:${port}"
                exec ${cfg.package}/bin/db-rest
              '';
          }
      ))
    ];

    users.groups = lib.mkIf (cfg.group == "db-rest") { db-rest = { }; };

    users.users = lib.mkMerge [
      (lib.mkIf (cfg.user == "db-rest") {
        db-rest = {
          group = cfg.group;
          isSystemUser = true;
        };
      })
      (lib.mkIf cfg.redis.createLocally { ${cfg.user}.extraGroups = [ "redis-db-rest" ]; })
    ];
  };

  meta.maintainers = with maintainers; [ marie ];
}
