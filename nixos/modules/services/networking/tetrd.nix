{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.services.tetrd.enable = lib.mkEnableOption "tetrd";

  config = lib.mkIf config.services.tetrd.enable {
    environment = {
      etc."resolv.conf".source = "/etc/tetrd/resolv.conf";
      systemPackages = [ pkgs.tetrd ];
    };

    # Our resolv.conf will override resolvconf's version.
    networking.resolvconf.enable = false;

    systemd = {
      services.tetrd = {
        description = pkgs.tetrd.meta.description;

        serviceConfig = {
          AmbientCapabilities = [
            "CAP_NET_ADMIN"
          ];

          BindPaths = [
            "/etc/tetrd/resolv.conf:/etc/resolv.conf"
            "/run/tetrd:/run"
          ];

          BindReadOnlyPaths = [
            builtins.storeDir
            "/etc/ssl"
            "/etc/static/ssl"
            "${pkgs.net-tools}/bin/route:/usr/bin/route"
            "${pkgs.net-tools}/bin/ifconfig:/usr/bin/ifconfig"
          ];

          CapabilityBoundingSet = [
            "CAP_NET_ADMIN"
          ];

          DeviceAllow = "usb_device";
          DynamicUser = true;
          ExecStart = "${pkgs.tetrd}/opt/Tetrd/bin/tetrd";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateMounts = true;
          PrivateNetwork = lib.mkDefault false;
          PrivateTmp = true;
          PrivateUsers = lib.mkDefault false;
          ProtectClock = lib.mkDefault false;
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

          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
            "AF_NETLINK"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RootDirectory = "/run/tetrd";
          RuntimeDirectory = "tetrd";
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@aio"
            "~@chown"
            "~@clock"
            "~@cpu-emulation"
            "~@debug"
            "~@keyring"
            "~@memlock"
            "~@module"
            "~@mount"
            "~@obsolete"
            "~@pkey"
            "~@raw-io"
            "~@reboot"
            "~@swap"
            "~@sync"
          ];

          UMask = "006";
        };

        wantedBy = [ "multi-user.target" ];
      };

      tmpfiles.rules = [ "f /etc/tetrd/resolv.conf - - -" ];
    };
  };
}
