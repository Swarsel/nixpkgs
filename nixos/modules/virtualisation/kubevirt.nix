{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../profiles/qemu-guest.nix
    ../image/file-options.nix
  ];

  config = {
    boot.growPartition = true;
    boot.kernelParams = [ "console=ttyS0" ];
    boot.loader.grub.device = "/dev/vda";
    boot.loader.timeout = 0;

    fileSystems."/" = {
      autoResize = true;
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    image.extension = "qcow2";
    services.cloud-init.enable = true;
    services.openssh.enable = true;
    services.qemuGuest.enable = true;
    system.build.image = config.system.build.kubevirtImage;

    system.build.kubevirtImage = import ../../lib/make-disk-image.nix {
      inherit lib config pkgs;
      inherit (config.image) baseName;
      format = "qcow2";
    };

    system.nixos.tags = [ "kubevirt" ];
    systemd.services."serial-getty@ttyS0".enable = true;
  };
}
