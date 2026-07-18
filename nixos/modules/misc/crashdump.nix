{
  config,
  lib,
  pkgs,
  ...
}:
let
  crashdump = config.boot.crashDump;

  kernelParams = lib.concatStringsSep " " crashdump.kernelParams;

in
###### interface
{
  options = {
    boot = {
      crashDump = {
        enable = lib.mkOption {
          default = false;

          description = ''
            If enabled, NixOS will set up a kernel that will
            boot on crash, and leave the user in systemd rescue
            to be able to save the crashed kernel dump at
            /proc/vmcore.
            It also activates the NMI watchdog.
          '';

          type = lib.types.bool;
        };

        kernelParams = lib.mkOption {
          default = [
            "1"
            "boot.shell_on_fail"
          ];

          description = ''
            Parameters that will be passed to the kernel kexec-ed on crash.
          '';

          type = lib.types.listOf lib.types.str;
        };

        reservedMemory = lib.mkOption {
          default = "128M";

          description = ''
            The amount of memory reserved for the crashdump kernel.
            If you choose a too high value, dmesg will mention
            "crashkernel reservation failed".
          '';

          type = lib.types.str;
        };
      };
    };
  };

  ###### implementation

  config = lib.mkIf crashdump.enable {
    boot = {
      kernelParams = [
        "crashkernel=${crashdump.reservedMemory}"
        "nmi_watchdog=panic"
        "softlockup_panic=1"
      ];

      postBootCommands = ''
        echo "loading crashdump kernel...";
        ${pkgs.kexec-tools}/sbin/kexec -p /run/current-system/kernel \
        --initrd=/run/current-system/initrd \
        --reset-vga --console-vga \
        --command-line="init=$(readlink -f /run/current-system/init) irqpoll maxcpus=1 reset_devices ${kernelParams}"
      '';
    };
  };
}
