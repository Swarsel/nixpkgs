{
  config,
  lib,
  pkgs,
  ...
}:
let
  boolToStr = value: if value then "on" else "off";
  cfg = config.vmware;

  subformats = [
    "monolithicSparse"
    "monolithicFlat"
    "twoGbMaxExtentSparse"
    "twoGbMaxExtentFlat"
    "streamOptimized"
  ];

in
{
  imports = [
    ../image/file-options.nix
    (lib.mkRenamedOptionModuleWith {
      from = [
        "vmware"
        "vmFileName"
      ];

      sinceRelease = 2505;

      to = [
        "image"
        "fileName"
      ];
    })
    (lib.modules.mkRenamedOptionModuleWith {
      from = [
        "vmware"
        "baseImageSize"
      ];

      sinceRelease = 2605;

      to = [
        "virtualisation"
        "diskSize"
      ];
    })
  ];

  options = {
    vmware = {
      vmCompat6 = lib.mkOption {
        default = false;
        description = "Create a VMDK version 6 image (instead of version 4).";
        example = true;
        type = lib.types.bool;
      };

      vmDerivationName = lib.mkOption {
        default = "nixos-vmware-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";

        description = ''
          The name of the derivation for the VMWare appliance.
        '';

        type = lib.types.str;
      };

      vmSubformat = lib.mkOption {
        default = "monolithicSparse";
        description = "Specifies which VMDK subformat to use.";
        type = lib.types.enum subformats;
      };
    };
  };

  config = {
    boot.growPartition = true;

    boot.loader.grub = {
      device = "nodev";
      efiInstallAsRemovable = true;
      efiSupport = true;
    };

    fileSystems."/" = {
      autoResize = true;
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };

    image.extension = "vmdk";
    system.build.image = config.system.build.vmwareImage;

    system.build.vmwareImage = import ../../lib/make-disk-image.nix {
      inherit config lib pkgs;
      baseName = config.image.baseName;
      diskSize = config.virtualisation.diskSize;
      format = "raw";
      name = cfg.vmDerivationName;
      partitionTableType = "efi";

      postVM = ''
        ${pkgs.vmTools.qemu}/bin/qemu-img convert -f raw -o compat6=${boolToStr cfg.vmCompat6},subformat=${cfg.vmSubformat} -O vmdk $diskImage $out/${config.image.fileName}
        rm $diskImage
      '';
    };

    system.nixos.tags = [ "vmware" ];
    virtualisation.vmware.guest.enable = true;
  };
}
