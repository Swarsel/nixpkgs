{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.matter-server;
  storageDir = "matter-server";
  storagePath = "/var/lib/${storageDir}";
  vendorId = "4939"; # home-assistant vendor ID
in

{
  options.services.matter-server = {
    enable = lib.mkEnableOption "Matter-server";
    package = lib.mkPackageOption pkgs "python-matter-server" { };

    extraArgs = lib.mkOption {
      default = { };

      description = ''
        Attribute set of extra arguments to pass to the matter-server executable.
        See <https://github.com/home-assistant-libs/python-matter-server?tab=readme-ov-file#running-the-development-server> for options.
      '';

      type = lib.types.attrs;
    };

    logLevel = lib.mkOption {
      default = "info";
      description = "Verbosity of logs from the matter-server";

      type = lib.types.enum [
        "critical"
        "error"
        "warning"
        "info"
        "debug"
      ];
    };

    openFirewall = lib.mkOption {
      default = false;
      description = "Whether to open the port in the firewall.";
      type = lib.types.bool;
    };

    port = lib.mkOption {
      default = 5580;
      description = "Port to expose the matter-server service on.";
      type = lib.types.port;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.matter-server = {
      after = [ "network-online.target" ];
      before = [ "home-assistant.service" ];
      description = "Matter Server";

      environment = {
        HOME = storagePath;
        SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      };

      script = ''
        # `python-matter-server` writes to /data even when a storage-path is
        # specified. This symlinks /data at the systemd-managed
        # /var/lib/matter-server, so all files get dropped into the state
        # directory.
        ln -s $STATE_DIRECTORY $RUNTIME_DIRECTORY/data

        # Create directories to hold certificates and OTA updates.
        CERT_DIR="$CACHE_DIRECTORY/certs"
        mkdir -p "$CERT_DIR"
        OTA_UPDATE_DIR="$CACHE_DIRECTORY/updates"
        mkdir -p "$OTA_UPDATE_DIR"

        "${lib.getExe cfg.package}" ${
          lib.concatStringsSep " " (
            lib.cli.toCommandLineGNU { } (
              {
                log-level = cfg.logLevel;
                ota-provider-dir = "$OTA_UPDATE_DIR";
                paa-root-cert-dir = "$CERT_DIR";
                port = cfg.port;
                storage-path = storagePath;
                vendorid = vendorId;
              }
              // cfg.extraArgs
            )
          )
        }
      '';

      serviceConfig = {
        # Hardening bits
        AmbientCapabilities = "";

        BindReadOnlyPaths = [
          "/nix/store" # To allow the binary to find its dependencies.
          "/run/dbus"
          "/etc/resolv.conf" # For DNS resolution.
        ];

        CacheDirectory = [ "matter-server" ];
        CapabilityBoundingSet = "";
        DevicePolicy = "closed";
        DynamicUser = true;
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

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RootDirectory = "%t/matter-server/root";
        # Start with a clean root filesystem, and allowlist what the container
        # is permitted to access.
        # See https://discourse.nixos.org/t/hardening-systemd-services/17147/14.
        RuntimeDirectory = [ "matter-server/root" ];
        # Let systemd manage `/var/lib/matter-server` for us inside the
        # ephemeral TemporaryFileSystem.
        StateDirectory = storageDir;

        SystemCallFilter = lib.concatStringsSep " " [
          "~" # Blocklist
          "@clock"
          "@cpu-emulation"
          "@debug"
          "@module"
          "@mount"
          "@obsolete"
          "@privileged"
          "@raw-io"
          "@reboot"
          "@resources"
          "@swap"
        ];

        UMask = "0077";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ leonm1 ];
}
