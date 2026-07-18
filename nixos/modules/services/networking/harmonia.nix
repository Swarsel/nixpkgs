{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.harmonia;
  cacheCfg = cfg.cache;
  daemonCfg = cfg.daemon;

  format = pkgs.formats.toml { };

  signKeyPaths =
    cacheCfg.signKeyPaths ++ (if cacheCfg.signKeyPath != null then [ cacheCfg.signKeyPath ] else [ ]);
  credentials = lib.imap0 (i: signKeyPath: {
    id = "sign-key-${toString i}";
    path = signKeyPath;
  }) signKeyPaths;
in
{
  imports = [
    # Renamed options for flat harmonia -> harmonia.cache
    (lib.mkRenamedOptionModule
      [ "services" "harmonia" "enable" ]
      [ "services" "harmonia" "cache" "enable" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "harmonia" "signKeyPath" ]
      [ "services" "harmonia" "cache" "signKeyPath" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "harmonia" "signKeyPaths" ]
      [ "services" "harmonia" "cache" "signKeyPaths" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "harmonia" "settings" ]
      [ "services" "harmonia" "cache" "settings" ]
    )
    # Note: package stays at the top level
  ];

  options = {
    services.harmonia = {
      package = lib.mkPackageOption pkgs "harmonia" { };

      cache = {
        enable = lib.mkEnableOption "Harmonia: Nix binary cache written in Rust";

        settings = lib.mkOption {
          inherit (format) type;
          default = { };

          description = ''
            Settings to merge with the default configuration.
            For the list of the default configuration, see <https://github.com/nix-community/harmonia/tree/master#configuration>.
          '';
        };

        signKeyPath = lib.mkOption {
          default = null;
          description = "DEPRECATED: Use `services.harmonia.cache.signKeyPaths` instead. Path to the signing key to use for signing the cache";
          type = lib.types.nullOr lib.types.path;
        };

        signKeyPaths = lib.mkOption {
          default = [ ];
          description = "Paths to the signing keys to use for signing the cache";
          type = lib.types.listOf lib.types.path;
        };
      };

      daemon = {
        enable = lib.mkEnableOption "Harmonia daemon: Nix daemon protocol implementation";

        dbPath = lib.mkOption {
          default = "/nix/var/nix/db/db.sqlite";
          description = "Path to the Nix database";
          type = lib.types.str;
        };

        logLevel = lib.mkOption {
          default = "info";
          description = "Log level for the daemon";
          type = lib.types.str;
        };

        socketPath = lib.mkOption {
          default = "/run/harmonia-daemon/socket";
          description = "Path where the daemon socket will be created";
          type = lib.types.str;
        };

        storeDir = lib.mkOption {
          default = "/nix/store";
          description = "Path to the Nix store directory";
          type = lib.types.str;
        };
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cacheCfg.enable {
      services.harmonia.cache.settings = builtins.mapAttrs (_: v: lib.mkDefault v) {
        bind = "[::]:5000";
        max_connection_rate = 256;
        priority = 50;
        workers = 4;
      };

      systemd.services.harmonia = {
        after = [ "harmonia.socket" ];
        description = "harmonia binary cache service";

        environment = {
          CONFIG_FILE = format.generate "harmonia.toml" cacheCfg.settings;
          # Note: it's important to set this for nix-store, because it wants to use
          # $HOME in order to use a temporary cache dir. bizarre failures will occur
          # otherwise
          HOME = "/run/harmonia";

          SIGN_KEY_PATHS = lib.strings.concatMapStringsSep " " (
            credential: "%d/${credential.id}"
          ) credentials;
        };

        requires = [ "harmonia.socket" ];

        serviceConfig = {
          CapabilityBoundingSet = "";
          DeviceAllow = [ "" ];
          DynamicUser = true;
          ExecStart = lib.getExe cfg.package;
          Group = "harmonia";
          IPAddressDeny = "any";
          LimitNOFILE = 65536;
          LoadCredential = map (credential: "${credential.id}:${credential.path}") credentials;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          # accept(2) on the inherited fd is exempt from both restrictions.
          PrivateNetwork = true;
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
          Restart = "on-failure";
          RestrictAddressFamilies = [ "AF_UNIX" ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RuntimeDirectory = "harmonia";
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
            "~@resources"
          ];

          Type = "notify";
          UMask = "0066";
          User = "harmonia";
          WatchdogSec = 15;
        };
      };

      # Socket activation lets the service run with PrivateNetwork; the
      # inherited fd keeps referring to the host netns.
      systemd.sockets.harmonia = {
        description = "harmonia binary cache socket";

        socketConfig.ListenStream =
          let
            b = cacheCfg.settings.bind;
          in
          if lib.hasPrefix "unix:" b then lib.removePrefix "//" (lib.removePrefix "unix:" b) else b;

        wantedBy = [ "sockets.target" ];
      };

      warnings =
        if cacheCfg.signKeyPath != null then
          [
            "`services.harmonia.cache.signKeyPath` is deprecated, use `services.harmonia.cache.signKeyPaths` instead"
          ]
        else
          [ ];
    })

    (lib.mkIf daemonCfg.enable {
      systemd.services.harmonia-daemon =
        let
          daemonConfig = {
            db_path = daemonCfg.dbPath;
            log_level = daemonCfg.logLevel;
            socket_path = daemonCfg.socketPath;
            store_dir = daemonCfg.storeDir;
          };
          daemonConfigFile = format.generate "harmonia-daemon.toml" daemonConfig;
        in
        {
          after = [ "network.target" ];
          description = "Harmonia Nix daemon protocol server";

          environment = {
            HARMONIA_DAEMON_CONFIG = daemonConfigFile;
            RUST_BACKTRACE = "1";
            RUST_LOG = daemonCfg.logLevel;
          };

          serviceConfig = {
            # Capabilities
            CapabilityBoundingSet = "";
            # Device access
            DeviceAllow = [ "" ];
            ExecStart = lib.getExe' cfg.package "harmonia-daemon";
            # Resource limits
            LimitNOFILE = 65536;
            LockPersonality = true;
            # Memory protection
            MemoryDenyWriteExecute = true;
            # Run as root to access the Nix database
            # Note: The Nix database is owned by root and requires root access
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateMounts = true;
            PrivateNetwork = false;
            PrivateTmp = true;
            # Process visibility
            ProcSubset = "pid";
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHome = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            # Kernel protection
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectProc = "invisible";
            ProtectSystem = "strict";

            ReadOnlyPaths = [
              daemonCfg.storeDir
            ];

            # SQLite needs write access for WAL mode
            ReadWritePaths = [
              (builtins.dirOf daemonCfg.dbPath) # Need write access for WAL and SHM files
            ];

            Restart = "on-failure";
            RestartSec = 5;
            # Network restrictions
            RestrictAddressFamilies = "AF_UNIX";
            # Namespace restrictions
            RestrictNamespaces = true;
            RestrictRealtime = true;
            # Socket will be created at runtime
            RuntimeDirectory = "harmonia-daemon";
            SystemCallArchitectures = "native";

            # System call filtering
            SystemCallFilter = [
              "@system-service"
              "~@privileged"
              "@chown" # for sockets
              "~@resources"
            ];

            Type = "simple";
            # Misc restrictions
            UMask = "0077";
          };

          wantedBy = [ "multi-user.target" ];
        };
    })
  ];
}
