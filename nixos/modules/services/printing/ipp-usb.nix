{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    services.ipp-usb = {
      enable = lib.mkEnableOption "ipp-usb, a daemon to turn an USB printer/scanner supporting IPP everywhere (aka AirPrint, WSD, AirScan) into a locally accessible network printer/scanner";
    };
  };

  config = lib.mkIf config.services.ipp-usb.enable {
    hardware.sane.enable = lib.mkDefault true;
    # so that sane discovers scanners
    hardware.sane.extraBackends = [ pkgs.sane-airscan ];

    services.avahi = {
      enable = true;

      publish = {
        enable = true;
        userServices = true;
      };
    };

    # enable printing and scanning by default, but not required.
    services.printing.enable = lib.mkDefault true;
    # starts the systemd service
    services.udev.packages = [ pkgs.ipp-usb ];

    systemd.services.ipp-usb = {
      after = [
        "cups.service"
        "avahi-daemon.service"
      ];

      description = "Daemon for IPP over USB printer support";

      serviceConfig = {
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        ExecStart = [ "${pkgs.ipp-usb}/bin/ipp-usb" ];
        LogsDirectory = "ipp-usb";
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        # breaks the daemon, presumably because it messes with DeviceAllow
        ProtectClock = false;
        ProtectControlGroups = true;
        # hardening.
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "noaccess";
        ProtectSystem = "strict";
        RemoveIPC = true;
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_NETLINK"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "ipp-usb";
        SystemCallArchitectures = "native";
        Type = "simple";
      };

      wants = [ "avahi-daemon.service" ];
    };
  };
}
