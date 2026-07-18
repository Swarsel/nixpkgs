{
  config,
  lib,
  pkgs,
  ...
}:

let
  serialDevice = if pkgs.stdenv.hostPlatform.isx86 then "ttyS0" else "ttyAMA0";
in
{
  imports = [
    ./lxc-instance-common.nix

    ../profiles/qemu-guest.nix
  ];

  config = {
    boot.growPartition = true;

    boot.kernelParams = [
      "console=tty1"
      "console=${serialDevice}"
    ];

    # image building needs to know what device to install bootloader on
    boot.loader.grub.device = "/dev/vda";
    boot.loader.systemd-boot.enable = true;

    fileSystems = {
      "/" = {
        autoResize = true;
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

      "/boot" = {
        device = "/dev/disk/by-label/ESP";
        fsType = "vfat";
      };
    };

    # CPU hotplug
    services.udev.extraRules = ''
      SUBSYSTEM=="cpu", CONST{arch}=="x86-64", TEST=="online", ATTR{online}=="0", ATTR{online}="1"
    '';

    system.build.qemuImage = import ../../lib/make-disk-image.nix {
      inherit pkgs lib config;
      copyChannel = config.system.installer.channel.enable;
      format = "qcow2-compressed";
      partitionTableType = "efi";
    };

    virtualisation.incus.agent.enable = lib.mkDefault true;
  };

  meta = {
    teams = [ lib.teams.lxc ];
  };
}
