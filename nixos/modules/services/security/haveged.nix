{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.haveged;

in

{

  ###### interface

  options = {

    services.haveged = {

      enable = lib.mkEnableOption ''
        haveged entropy daemon, which refills /dev/random when low.
        NOTE: does nothing on kernels newer than 5.6
      '';

      # source for the note https://github.com/jirka-h/haveged/issues/57

      refill_threshold = lib.mkOption {
        default = 1024;

        description = ''
          The number of bits of available entropy beneath which
          haveged should refill the entropy pool.
        '';

        type = lib.types.int;
      };

    };

  };

  config = lib.mkIf cfg.enable {

    # https://github.com/jirka-h/haveged/blob/a4b69d65a8dfc5a9f52ff8505c7f58dcf8b9234f/contrib/Fedora/haveged.service
    systemd.services.haveged = {
      after = [ "systemd-tmpfiles-setup-dev.service" ];

      before = [
        "sysinit.target"
        "shutdown.target"
        "systemd-journald.service"
      ];

      description = "Entropy Daemon based on the HAVEGE algorithm";

      serviceConfig = {
        CapabilityBoundingSet = [
          "CAP_SYS_ADMIN"
          "CAP_SYS_CHROOT"
        ];

        ExecStart = "${pkgs.haveged}/bin/haveged -w ${toString cfg.refill_threshold} --Foreground -v 1";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        # We can *not* set PrivateTmp=true as it can cause an ordering cycle.
        PrivateTmp = false;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectSystem = "full";
        Restart = "always";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SecureBits = "noroot-locked";
        SuccessExitStatus = "137 143";
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";

        SystemCallFilter = [
          "@system-service"
          "newuname"
          "~@mount"
        ];
      };

      unitConfig = {
        ConditionKernelVersion = "<5.6";
        DefaultDependencies = false;
        Documentation = "man:haveged(8)";
      };

      wantedBy = [ "sysinit.target" ];

    };
  };

}
