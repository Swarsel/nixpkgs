{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.flaresolverr;
in
{
  options = {
    services.flaresolverr = {
      enable = lib.mkEnableOption "FlareSolverr, a proxy server to bypass Cloudflare protection";
      package = lib.mkPackageOption pkgs "flaresolverr" { };

      openFirewall = lib.mkOption {
        default = false;
        description = "Open the port in the firewall for FlareSolverr.";
        type = lib.types.bool;
      };

      port = lib.mkOption {
        default = 8191;
        description = "The port on which FlareSolverr will listen for incoming HTTP traffic.";
        type = lib.types.port;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };

    systemd.services.flaresolverr = {
      after = [ "network.target" ];
      description = "FlareSolverr";

      environment = {
        HOME = "/run/flaresolverr";
        PORT = toString cfg.port;
      };

      serviceConfig = {
        CapabilityBoundingSet = [
          "~CAP_BLOCK_SUSPEND"
          "~CAP_BPF"
          "~CAP_CHOWN"
          "~CAP_IPC_LOCK"
          "~CAP_MKNOD"
          "~CAP_NET_ADMIN"
          "~CAP_NET_RAW"
          "~CAP_PERFMON"
          "~CAP_SYSLOG"
          "~CAP_SYS_ADMIN"
          "~CAP_SYS_BOOT"
          "~CAP_SYS_MODULE"
          "~CAP_SYS_PACCT"
          "~CAP_SYS_PTRACE"
          "~CAP_SYS_TIME"
          "~CAP_WAKE_ALARM"
        ];

        DynamicUser = true;
        ExecStart = lib.getExe cfg.package;
        # Systemd hardening
        LockPersonality = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        Restart = "always";
        RestartSec = 5;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = [
          "net"
          "pid"
          "user"
        ];

        RestrictRealtime = true;
        RuntimeDirectory = "flaresolverr";
        SyslogIdentifier = "flaresolverr";
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";

        SystemCallFilter = [
          "~@chown"
          "~@clock"
          "~@cpu-emulation"
          "~@debug"
          "~@keyring"
          "~@memlock"
          "~@module"
          "~@obsolete"
          "~@pkey"
          "~@raw-io"
          "~@reboot"
          "~@setuid"
          "~@swap"
          "~@timer"
        ];

        TimeoutStopSec = 30;
        Type = "simple";
        UMask = "0077";
        WorkingDirectory = "/run/flaresolverr";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ diogotcorreia ];
}
