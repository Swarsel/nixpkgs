{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.zipline;
in
{
  options.services.zipline = {
    enable = lib.mkEnableOption "Zipline";
    package = lib.mkPackageOption pkgs "zipline" { };

    database.createLocally = lib.mkOption {
      default = true;

      description = ''
        Whether to enable and configure a local PostgreSQL database server.
      '';

      type = lib.types.bool;
    };

    environmentFiles = lib.mkOption {
      default = [ ];

      description = ''
        Files to load environment variables from (in addition to [](#opt-services.zipline.settings)). This is useful to avoid putting secrets into the nix store. See <https://zipline.diced.sh/docs/config> for more information.
      '';

      example = [ "/run/secrets/zipline.env" ];
      type = lib.types.listOf lib.types.path;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration of Zipline. See <https://zipline.diced.sh/docs/config> for more information.
      '';

      example = {
        CORE_HOSTNAME = "0.0.0.0";
        CORE_PORT = "3000";
        CORE_SECRET = "changethis";
        DATABASE_URL = "postgres://postgres:postgres@postgres/postgres";
        DATASOURCE_LOCAL_DIRECTORY = "/var/lib/zipline/uploads";
        DATASOURCE_TYPE = "local";
      };

      type = lib.types.submodule {
        options = {
          CORE_HOSTNAME = lib.mkOption {
            default = "127.0.0.1";
            description = "The hostname to listen on.";
            example = "0.0.0.0";
            type = lib.types.str;
          };

          CORE_PORT = lib.mkOption {
            default = 3000;
            description = "The port to listen on.";
            example = 8000;
            type = lib.types.port;
          };
        };

        freeformType =
          with lib.types;
          attrsOf (oneOf [
            str
            int
          ]);
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = lib.mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ "zipline" ];

      ensureUsers = lib.singleton {
        ensureDBOwnership = true;
        name = "zipline";
      };
    };

    services.zipline.settings = {
      DATABASE_URL = lib.mkIf cfg.database.createLocally "postgresql://zipline@localhost/zipline?host=/run/postgresql";
      DATASOURCE_LOCAL_DIRECTORY = lib.mkDefault "/var/lib/zipline/uploads"; # created automatically by zipline
      DATASOURCE_TYPE = lib.mkDefault "local";
    };

    systemd.services.zipline = {
      after = [ "network-online.target" ] ++ lib.optional cfg.database.createLocally "postgresql.target";
      environment = lib.mapAttrs (_: value: toString value) cfg.settings;
      requires = lib.optional cfg.database.createLocally "postgresql.target";

      serviceConfig = {
        # Hardening
        AmbientCapabilities = "";
        CapabilityBoundingSet = [ "" ];
        DevicePolicy = "closed";
        DynamicUser = true;
        EnvironmentFile = cfg.environmentFiles;
        ExecStart = lib.getExe cfg.package;
        Group = "zipline";
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
        RestrictAddressFamilies = [ "AF_INET AF_INET6 AF_UNIX AF_NETLINK" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "zipline";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
          "@chown"
        ];

        UMask = "0077";
        User = "zipline";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ defelo ];
}
