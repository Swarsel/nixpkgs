{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.shiori;
in
{
  options = {
    services.shiori = {
      enable = lib.mkEnableOption "Shiori simple bookmarks manager";
      package = lib.mkPackageOption pkgs "shiori" { };

      address = lib.mkOption {
        default = "";

        description = ''
          The IP address on which Shiori will listen.
          If empty, listens on all interfaces.
        '';

        type = lib.types.str;
      };

      databaseUrl = lib.mkOption {
        default = null;
        description = "The connection URL to connect to MySQL or PostgreSQL";
        example = "postgres:///shiori?host=/run/postgresql";
        type = lib.types.nullOr lib.types.str;
      };

      environmentFile = lib.mkOption {
        default = null;

        description = ''
          Path to file containing environment variables.
          Useful for passing down secrets.
          <https://github.com/go-shiori/shiori/blob/master/docs/Configuration.md#overall-configuration>
        '';

        example = "/path/to/environmentFile";
        type = lib.types.nullOr lib.types.path;
      };

      port = lib.mkOption {
        default = 8080;
        description = "The port of the Shiori web application";
        type = lib.types.port;
      };

      webRoot = lib.mkOption {
        default = "/";
        description = "The root of the Shiori web application";
        example = "/shiori";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.shiori = {
      after = [
        "postgresql.target"
        "mysql.service"
      ];

      description = "Shiori simple bookmarks manager";

      environment = {
        SHIORI_DIR = "/var/lib/shiori";
      }
      // lib.optionalAttrs (cfg.databaseUrl != null) {
        SHIORI_DATABASE_URL = cfg.databaseUrl;
      };

      serviceConfig = {
        BindReadOnlyPaths = [
          "/nix/store"

          # For SSL certificates, and the resolv.conf
          "/etc"
        ]
        ++ lib.optional (
          config.services.postgresql.enable
          && cfg.databaseUrl != null
          && lib.strings.hasPrefix "postgres://" cfg.databaseUrl
        ) "/run/postgresql"
        ++ lib.optional (
          config.services.mysql.enable
          && cfg.databaseUrl != null
          && lib.strings.hasPrefix "mysql://" cfg.databaseUrl
        ) "/var/run/mysqld";

        CapabilityBoundingSet = "";
        DeviceAllow = "";
        DynamicUser = true;
        # Security options
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = "${cfg.package}/bin/shiori server --address '${cfg.address}' --port '${toString cfg.port}' --webroot '${cfg.webRoot}'";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RootDirectory = "/run/shiori";
        # As the RootDirectory
        RuntimeDirectory = "shiori";
        StateDirectory = "shiori";
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";

        SystemCallFilter = [
          "@system-service"
          "~@cpu-emulation"
          "~@debug"
          "~@keyring"
          "~@memlock"
          "~@obsolete"
          "~@privileged"
          "~@setuid"
        ];
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    minijackson
    CaptainJawZ
  ];
}
