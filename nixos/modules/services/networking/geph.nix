{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.geph;
in
{
  options.services.geph = {
    enable = lib.mkEnableOption "geph client daemon";
    package = lib.mkPackageOption pkgs "geph" { };

    configFile = lib.mkOption {
      description = ''
        Path to the geph config file.

        This file contain sensitive credentials, so it must not live in the Nix store.
      '';

      type = lib.types.pathWith {
        absolute = true;
        inStore = false;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "tun" ];
    networking.firewall.checkReversePath = "loose";

    systemd.services.geph = {
      after = [ "network-online.target" ];
      description = "geph client daemon";

      serviceConfig = {
        AmbientCapabilities = [
          "CAP_NET_ADMIN"
          "CAP_NET_BIND_SERVICE"
        ];

        CapabilityBoundingSet = [
          "CAP_NET_ADMIN"
          "CAP_NET_BIND_SERVICE"
        ];

        DeviceAllow = "/dev/net/tun rw";
        DevicePolicy = "closed";
        DynamicUser = true;
        ExecStart = "${lib.getExe cfg.package} --config %d/geph-config";
        LimitNOFILE = 65535;
        LoadCredential = "geph-config:${cfg.configFile}";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = false;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = false;
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
        RestartSec = 2;

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "geph";
        StateDirectoryMode = "0700";
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
        UMask = "0077";
        WorkingDirectory = "/var/lib/geph";
      };

      startLimitBurst = 5;
      startLimitIntervalSec = 20;
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta = {
    maintainers = with lib.maintainers; [
      MCSeekeri
    ];
  };
}
