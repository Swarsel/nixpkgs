{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types mkIf;
  cfg = config.services.atuin;
in
{
  options = {
    services.atuin = {
      enable = lib.mkEnableOption "Atuin server for shell history sync";
      package = lib.mkPackageOption pkgs "atuin" { };

      database = {
        createLocally = mkOption {
          default = true;
          description = "Create the database and database user locally.";
          type = types.bool;
        };

        uri = mkOption {
          default = "postgresql:///atuin?host=/run/postgresql";

          description = ''
            URI to the database.
            Can be set to null in which case ATUIN_DB_URI should be set through an EnvironmentFile
          '';

          example = "postgresql://atuin@localhost:5432/atuin";
          type = types.nullOr types.str;
        };
      };

      environmentFile = lib.mkOption {
        default = null;

        description = ''
          Environment file, used to set any secret ATUIN_* environment variables, such as ATUIN_DB_URI containing a password.
          See https://docs.atuin.sh/cli/self-hosting/server-setup/#configuration for available environment variables.
        '';

        type = lib.types.nullOr lib.types.externalPath;
      };

      host = mkOption {
        default = "127.0.0.1";
        description = "The host address the atuin server should listen on.";
        type = types.str;
      };

      maxHistoryLength = mkOption {
        default = 8192;
        description = "The max length of each history item the atuin server should store.";
        type = types.int;
      };

      openFirewall = mkOption {
        default = false;
        description = "Open ports in the firewall for the atuin server.";
        type = types.bool;
      };

      openRegistration = mkOption {
        default = false;
        description = "Allow new user registrations with the atuin server.";
        type = types.bool;
      };

      path = mkOption {
        default = "";
        description = "A path to prepend to all the routes of the server.";
        type = types.str;
      };

      port = mkOption {
        default = 8888;
        description = "The port the atuin server should listen on.";
        type = types.port;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.database.createLocally -> config.services.postgresql.enable;
        message = "Postgresql must be enabled to create a local database";
      }
    ];

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    services.postgresql = mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ "atuin" ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = "atuin";
        }
      ];
    };

    systemd.services.atuin = {
      after = [
        "network-online.target"
      ]
      ++ lib.optionals cfg.database.createLocally [ "postgresql.target" ];

      description = "atuin server";

      environment = {
        ATUIN_CONFIG_DIR = "/run/atuin"; # required to start, but not used as configuration is via environment variables
        ATUIN_HOST = cfg.host;
        ATUIN_MAX_HISTORY_LENGTH = toString cfg.maxHistoryLength;
        ATUIN_OPEN_REGISTRATION = lib.boolToString cfg.openRegistration;
        ATUIN_PATH = cfg.path;
        ATUIN_PORT = toString cfg.port;
      }
      // lib.optionalAttrs (cfg.database.uri != null) { ATUIN_DB_URI = cfg.database.uri; };

      requires = lib.optionals cfg.database.createLocally [ "postgresql.target" ];

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = "";
        DynamicUser = true;
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];
        ExecStart = "${lib.getExe' cfg.package "atuin-server"} start";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
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
        ProtectSystem = "full";
        RemoveIPC = true;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          # Required for connecting to database sockets,
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "atuin";
        RuntimeDirectoryMode = "0700";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        UMask = "0077";
      };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "network-online.target"
      ]
      ++ lib.optionals cfg.database.createLocally [ "postgresql.target" ];
    };
  };
}
