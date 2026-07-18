{ config, lib, ... }:
{
  options = {
    security.lockKernelModules = lib.mkOption {
      default = false;

      description = ''
        Disable kernel module loading once the system is fully initialised.
        Module loading is disabled until the next reboot. Problems caused
        by delayed module loading can be fixed by adding the module(s) in
        question to {option}`boot.kernelModules`.
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf config.security.lockKernelModules {
    boot.kernelModules = lib.concatMap (
      x:
      lib.optionals (x.device != null) (
        if x.fsType == "vfat" then
          [
            "vfat"
            "nls-cp437"
            "nls-iso8859-1"
          ]
        else
          [ x.fsType ]
      )
    ) config.system.build.fileSystems;

    systemd.services.disable-kernel-module-loading = {
      after = [
        "firewall.service"
        "systemd-modules-load.service"
        config.systemd.defaultUnit
      ];

      description = "Disable kernel module loading";

      script = ''
        ${config.systemd.package}/bin/udevadm settle
        echo -n 1 >/proc/sys/kernel/modules_disabled
      '';

      serviceConfig = {
        RemainAfterExit = true;
        TimeoutSec = 180;
        Type = "oneshot";
      };

      unitConfig.ConditionPathIsReadWrite = "/proc/sys/kernel";
      wantedBy = [ config.systemd.defaultUnit ];
      wants = [ "systemd-udevd.service" ];
    };
  };

  meta = {
    maintainers = [ ];
  };
}
