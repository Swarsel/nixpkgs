{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    maintainers
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.services.esphome;

  stateDir = "/var/lib/esphome";

  esphomeParams =
    if cfg.enableUnixSocket then
      "--socket /run/esphome/esphome.sock"
    else
      "--address ${cfg.address} --port ${toString cfg.port}";
in
{
  options.services.esphome = {
    enable = mkEnableOption "esphome, for making custom firmwares for ESP32/ESP8266";
    package = lib.mkPackageOption pkgs "esphome" { };

    address = mkOption {
      default = "localhost";
      description = "esphome address";
      type = types.str;
    };

    allowedDevices = mkOption {
      default = [
        "char-ttyS"
        "char-ttyUSB"
      ];

      description = ''
        A list of device nodes to which {command}`esphome` has access to.
        Refer to DeviceAllow in {manpage}`systemd.resource-control(5)` for more information.
        Beware that if a device is referred to by an absolute path instead of a device category,
        it will only allow devices that already are plugged in when the service is started.
      '';

      example = [
        "/dev/serial/by-id/usb-Silicon_Labs_CP2102_USB_to_UART_Bridge_Controller_0001-if00-port0"
      ];

      type = types.listOf types.str;
    };

    enableUnixSocket = mkOption {
      default = false;
      description = "Listen on a unix socket `/run/esphome/esphome.sock` instead of the TCP port.";
      type = types.bool;
    };

    environment = mkOption {
      default = { };

      description = ''
        Extra environment variables to pass to ESPHome. Secrets should be passed
        using the {option}`services.esphome.environmentFile` option.
      '';

      example = {
        PASSWORD = "gensokyo9";
        USERNAME = "reimu";
      };

      type = types.attrsOf types.str;
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        Path to an environment file.
        Use this option for setting the dashboard password.
      '';

      type = types.nullOr types.path;
    };

    openFirewall = mkOption {
      default = false;
      description = "Whether to open the firewall for the specified port.";
      type = types.bool;
    };

    port = mkOption {
      default = 6052;
      description = "esphome port";
      type = types.port;
    };

    usePing = mkOption {
      default = false;
      description = "Use ping to check online status of devices instead of mDNS";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf (cfg.openFirewall && !cfg.enableUnixSocket) [ cfg.port ];

    systemd.services.esphome = {
      after = [ "network.target" ];
      description = "ESPHome dashboard";

      environment = {
        # platformio needs a writable HOME for its configuration
        HOME = stateDir;
        # Set PLATFORMIO_CORE_DIR to a real path (not a symlink) so PlatformIO
        # and its downloaded toolchains can resolve paths correctly.
        PLATFORMIO_CORE_DIR = "${stateDir}/.platformio";
      }
      // lib.optionalAttrs cfg.usePing { ESPHOME_DASHBOARD_USE_PING = "true"; }
      // cfg.environment;

      path = [ cfg.package ];

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = "";
        DeviceAllow = map (d: "${d} rw") cfg.allowedDevices;
        DevicePolicy = "closed";
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
        ExecPaths = [ stateDir ];
        ExecStart = "${cfg.package}/bin/esphome dashboard ${esphomeParams} ${stateDir}";
        Group = "esphome";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProcSubset = "all"; # Using "pid" breaks bwrap
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = false; # breaks bwrap
        ProtectKernelLogs = false; # breaks bwrap
        ProtectKernelModules = true;
        ProtectKernelTunables = false; # breaks bwrap
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        ReadWritePaths = [ stateDir ];
        RemoveIPC = true;
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
          "AF_UNIX"
        ];

        RestrictNamespaces = false; # Required by platformio for chroot
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = mkIf cfg.enableUnixSocket "esphome";
        RuntimeDirectoryMode = "0750";
        StateDirectory = "esphome";
        StateDirectoryMode = "0750";
        SupplementaryGroups = [ "dialout" ];
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "@mount" # Required by platformio for chroot
        ];

        UMask = "0077";
        User = "esphome";
        WorkingDirectory = stateDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.esphome = { };

    # Use a static system user instead of DynamicUser.
    # DynamicUser creates a /var/lib/esphome -> /var/lib/private/esphome symlink
    # which breaks PlatformIO's path resolution during firmware compilation.
    # See: https://github.com/NixOS/nixpkgs/issues/339557
    users.users.esphome = {
      group = "esphome";
      home = stateDir;
      isSystemUser = true;
    };
  };

  meta.maintainers = with maintainers; [ oddlama ];
}
