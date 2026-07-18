{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.image;
in
{
  imports = [
    ./disk-size-option.nix
    ../image/file-options.nix
  ];

  options.image = {
    efiSupport = lib.mkOption {
      default = true;
      description = "Whether the disk image should support EFI boot or legacy boot";
      type = lib.types.bool;
    };

    format = lib.mkOption {
      default = "qcow2";
      description = "Format of the disk image to generate: raw or qcow2";

      type = lib.types.enum [
        "raw"
        "qcow2"
      ];
    };
  };

  config = {
    boot.growPartition = lib.mkDefault true;

    boot.loader.grub = lib.mkIf (!cfg.efiSupport) {
      enable = lib.mkOptionDefault true;
      devices = lib.mkDefault [ "/dev/vda" ];
    };

    boot.loader.systemd-boot.enable = lib.mkDefault cfg.efiSupport;

    fileSystems = {
      "/" = {
        autoResize = true;
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

      "/boot" = lib.mkIf (cfg.efiSupport) {
        device = "/dev/disk/by-label/ESP";
        fsType = "vfat";
      };
    };

    image.extension = if cfg.format == "raw" then "img" else cfg.format;

    system.build.image = import ../../lib/make-disk-image.nix {
      inherit lib config pkgs;
      inherit (config.virtualisation) diskSize;
      inherit (cfg) baseName format;
      partitionTableType = if cfg.efiSupport then "efi" else "legacy";
    };

    system.nixos.tags = [ cfg.format ] ++ lib.optionals cfg.efiSupport [ "efi" ];
  };
}
