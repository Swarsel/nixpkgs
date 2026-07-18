{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.nohang;

  inherit (lib)
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;
in
{
  options.services.nohang = {
    enable = mkEnableOption "nohang, a daemon that keeps system responsiveness when Linux is out of memory";
    package = mkPackageOption pkgs "nohang" { };

    configPath = mkOption {
      default = "desktop";

      description = ''
        Configuration file to use with nohang. The default and desktop example configurations in the nohang repository
        can be used by setting this to "basic" or "desktop" (which is the default). Otherwise, you can set it to the path
        of a custom configuration file.
      '';

      example = literalExpression "./my-nohang-config.conf";

      type = types.either (types.enum [
        "basic"
        "desktop"
      ]) types.path;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.nohang = {
      after = [ "sysinit.target" ];
      description = "Sophisticated low memory handler";

      documentation = [
        "man:nohang(8)"
        "https://github.com/hakavlad/nohang"
      ];

      serviceConfig = {
        CPUSchedulingResetOnFork = true;

        CapabilityBoundingSet = [
          "CAP_KILL"
          "CAP_IPC_LOCK"
          "CAP_SYS_PTRACE"
          "CAP_DAC_READ_SEARCH"
          "CAP_DAC_OVERRIDE"
          "CAP_AUDIT_WRITE"
          "CAP_SETUID"
          "CAP_SETGID"
          "CAP_SYS_RESOURCE"
          "CAP_SYSLOG"
        ];

        DeviceAllow = "/dev/kmsg rw";
        DevicePolicy = "closed";

        ExecStart =
          "${lib.getExe cfg.package} --monitor --config "
          + (
            if cfg.configPath == "basic" then
              "${cfg.package}/etc/nohang/nohang.conf"
            else if cfg.configPath == "desktop" then
              "${cfg.package}/etc/nohang/nohang-desktop.conf"
            else
              cfg.configPath
          );

        InaccessiblePaths = "/home /root";
        KillMode = "mixed";
        LockPersonality = "yes";
        MemoryDenyWriteExecute = "yes";
        MemoryMax = "100M";
        MemorySwapMax = "100M";
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        ReadWritePaths = "/var/log";
        Restart = "always";
        RestartSec = 0;
        RestrictNamespaces = "yes";
        RestrictRealtime = "yes";
        Slice = "hostcritical.slice";

        SyslogIdentifier =
          if cfg.configPath == "basic" then
            "nohang"
          else if cfg.configPath == "desktop" then
            "nohang-desktop"
          else
            "nohang-custom-config";

        TasksMax = 25;
        UMask = 27;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ Dev380 ];
  };
}
