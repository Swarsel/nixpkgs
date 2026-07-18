{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.hyperv;
in
{

  imports = [
    ./disk-size-option.nix
    ../image/file-options.nix
    (lib.mkRenamedOptionModuleWith {
      from = [
        "hyperv"
        "baseImageSize"
      ];

      sinceRelease = 2411;

      to = [
        "virtualisation"
        "diskSize"
      ];
    })
    (lib.mkRenamedOptionModuleWith {
      from = [
        "virtualisation"
        "hyperv"
        "vmFileName"
      ];

      sinceRelease = 2505;

      to = [
        "image"
        "fileName"
      ];
    })
  ];

  options = {
    hyperv = {
      vmDerivationName = mkOption {
        default = "nixos-hyperv-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";

        description = ''
          The name of the derivation for the hyper-v appliance.
        '';

        type = types.str;
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

    image.extension = "vhdx";

    system.build.hypervImage = import ../../lib/make-disk-image.nix {
      inherit (config.virtualisation) diskSize;
      inherit config lib pkgs;
      baseName = config.image.baseName;
      format = "raw";
      name = cfg.vmDerivationName;
      partitionTableType = "efi";

      postVM = ''
        ${pkgs.vmTools.qemu}/bin/qemu-img convert -f raw -o subformat=dynamic -O vhdx $diskImage $out/${config.image.fileName}
        rm $diskImage
      '';
    };

    system.build.image = config.system.build.hypervImage;
    system.nixos.tags = [ "hyperv" ];
    # Use a priority just below mkOptionDefault (1500) instead of lib.mkDefault
    # to avoid breaking existing configs using that.
    virtualisation.diskSize = lib.mkOverride 1490 (4 * 1024);
    virtualisation.hypervGuest.enable = true;
  };
}
