{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.prefect;
  inherit (lib.types)
    bool
    str
    enum
    path
    attrsOf
    nullOr
    submodule
    port
    ;

in
{
  options.services.prefect = {
    enable = lib.mkOption {
      default = false;
      description = "enable prefect server and worker services";
      type = bool;
    };

    package = lib.mkPackageOption pkgs "prefect" { };

    baseUrl = lib.mkOption {
      default = null;
      description = "external url when served by a reverse proxy, e.g. `https://example.com/prefect`";
      type = nullOr str;
    };

    dataDir = lib.mkOption {
      default = "/var/lib/prefect-server";

      description = ''
        Specify the directory for Prefect.
      '';

      type = path;
    };

    database = lib.mkOption {
      default = "sqlite";
      description = "which database to use for prefect server: sqlite or postgres";

      type = enum [
        "sqlite"
        "postgres"
      ];
    };

    databaseHost = lib.mkOption {
      default = "localhost";
      description = "database host for postgres only";
      type = str;
    };

    databaseName = lib.mkOption {
      default = "prefect";
      description = "database name for postgres only";
      type = str;
    };

    databasePasswordFile = lib.mkOption {
      default = null;

      description = ''
        path to a file containing e.g.:
          DBPASSWORD=supersecret

        stored outside the nix store, read by systemd as EnvironmentFile.
      '';

      type = nullOr str;
    };

    databasePort = lib.mkOption {
      default = "5432";
      description = "database port for postgres only";
      type = str;
    };

    databaseUser = lib.mkOption {
      default = "postgres";
      description = "database user for postgres only";
      type = str;
    };

    host = lib.mkOption {
      default = "127.0.0.1";
      description = "Prefect server host";
      example = "0.0.0.0";
      type = str;
    };

    port = lib.mkOption {
      default = 4200;
      description = "Prefect server port";
      type = port;
    };

    # now define workerPools as an attribute set of submodules,
    # each key is the pool name, and the submodule has an installPolicy
    workerPools = lib.mkOption {
      default = { };

      description = ''
        define a set of worker pools with submodule config. example:
        workerPools.my-pool = {
          installPolicy = "never";
        };
      '';

      type = attrsOf (submodule {
        options = {
          installPolicy = lib.mkOption {
            default = "always";
            description = "install policy for the worker (always, if-not-present, never, prompt)";

            type = enum [
              "always"
              "if-not-present"
              "never"
              "prompt"
            ];
          };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable {
    # define systemd.services as the server plus any worker definitions
    systemd.services = {
      "prefect-server" = {
        after = [ "network.target" ];
        description = "prefect server";

        serviceConfig = {
          AmbientCapabilities = [ ];
          CapabilityBoundingSet = [ ];
          DynamicUser = true;

          # TODO all my efforts to setup the database url
          # have failed with some unable to open file
          Environment = [
            "PREFECT_HOME=%S/prefect-server"
            "PREFECT_UI_STATIC_DIRECTORY=%S/prefect-server"
            "PREFECT_SERVER_ANALYTICS_ENABLED=off"
            "PREFECT_UI_API_URL=${cfg.baseUrl}/api"
            "PREFECT_UI_URL=${cfg.baseUrl}"
          ];

          EnvironmentFile =
            if cfg.database == "postgres" && cfg.databasePasswordFile != null then
              [ cfg.databasePasswordFile ]
            else
              [ ];

          ExecStart = "${lib.getExe cfg.package} server start --host ${cfg.host} --port ${toString cfg.port}";
          LockPersonality = true;
          MemoryAccounting = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          # ReadWritePaths = [ cfg.dataDir ];
          ProtectSystem = "strict";
          Restart = "always";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];

          RestrictSUIDSGID = true;
          StateDirectory = "prefect-server";
          WorkingDirectory = cfg.dataDir;
        };

        wantedBy = [ "multi-user.target" ];
      };
    }
    // lib.concatMapAttrs (poolName: poolCfg: {
      # return a partial attr set with one key: "prefect-worker-..."
      "prefect-worker-${poolName}" = {
        after = [ "network.target" ];
        description = "prefect worker for pool '${poolName}'";
        environment.systemPackages = cfg.package;

        serviceConfig = {
          AmbientCapabilities = [ ];
          CapabilityBoundingSet = [ ];
          DynamicUser = true;

          Environment = [
            "PREFECT_HOME=%S/prefect-worker-${poolName}"
            "PREFECT_API_URL=${cfg.baseUrl}/api"
          ];

          ExecStart = ''
            ${lib.getExe cfg.package} worker start \
              --pool ${poolName} \
              --type process \
              --install-policy ${poolCfg.installPolicy}
          '';

          LockPersonality = true;
          MemoryAccounting = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";
          Restart = "always";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];

          RestrictSUIDSGID = true;
          StateDirectory = "prefect-worker-${poolName}";
        };

        wantedBy = [ "multi-user.target" ];
      };
    }) cfg.workerPools;
  };
}
