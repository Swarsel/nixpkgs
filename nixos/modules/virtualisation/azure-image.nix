{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.virtualisation.azureImage;
in
{
  imports = [
    ./azure-common.nix
    ./disk-size-option.nix
    ../image/file-options.nix
    (lib.mkRenamedOptionModuleWith {
      from = [
        "virtualisation"
        "azureImage"
        "diskSize"
      ];

      sinceRelease = 2411;

      to = [
        "virtualisation"
        "diskSize"
      ];
    })
  ];

  options.virtualisation.azureImage = {
    additionalSpace = mkOption {
      default = "512M";

      description = ''
        additional disk space to be added to the image if diskSize "auto"
        is used.
      '';

      example = "2048M";
      type = types.str;
    };

    bootSize = mkOption {
      default = 256;

      description = ''
        ESP partition size. Unit is MB.
        Only effective when vmGeneration is `v2`.
      '';

      type = types.int;
    };

    contents = mkOption {
      default = [ ];

      description = ''
        Extra contents to add to the image.
      '';

      type = with types; listOf attrs;
    };

    label = mkOption {
      default = "nixos";

      description = ''
        NixOS partition label.
      '';

      type = types.str;
    };

    vmGeneration = mkOption {
      default = "v1";

      description = ''
        VM Generation to use.
        For v2, secure boot needs to be turned off during creation.
      '';

      type =
        with types;
        enum [
          "v1"
          "v2"
        ];
    };
  };

  config = {
    boot.growPartition = true;

    boot.loader.grub = rec {
      device = if efiSupport then "nodev" else "/dev/sda";
      efiInstallAsRemovable = efiSupport;
      efiSupport = (cfg.vmGeneration == "v2");

      # For Gen 1 VM, configurate grub output to serial_com0.
      # Not needed for Gen 2 VM wbere serial_com0 does not exist,
      # and outputting to console is enough to make Azure Serial Console working
      extraConfig = lib.mkIf (!efiSupport) ''
        serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
        terminal_input --append serial
        terminal_output --append serial
      '';

      # Force grub to run in text mode and output to console
      # by disabling font and splash image
      font = null;
      splashImage = null;
    };

    fileSystems = {
      "/" = {
        inherit (cfg) label;
        autoResize = true;
        device = "/dev/disk/by-label/${cfg.label}";
        fsType = "ext4";
      };

      "/boot" = lib.mkIf (cfg.vmGeneration == "v2") {
        device = "/dev/disk/by-label/ESP";
        fsType = "vfat";
      };
    };

    image.extension = "vhd";

    system.build.azureImage = import ../../lib/make-disk-image.nix {
      inherit (config.image) baseName;
      inherit (cfg) contents label;
      inherit (config.virtualisation) diskSize;
      inherit config lib pkgs;
      bootSize = "${toString cfg.bootSize}M";
      configFile = ./azure-config-user.nix;
      # Azure expects vhd format with fixed size,
      # generating raw format and convert with subformat args afterwards
      format = "raw";
      name = "azure-image";
      partitionTableType = if (cfg.vmGeneration == "v2") then "efi" else "legacy";

      postVM = ''
        ${lib.getExe' pkgs.vmTools.qemu "qemu-img"} convert -f raw -o subformat=fixed,force_size -O vpc $diskImage $out/${config.image.fileName}
        rm $diskImage
      ''
      + lib.optionalString (cfg.diskSize == "auto") ''
        truncate -s +${cfg.additionalSpace} "$out/${config.image.fileName}"
        ${lib.getExe' pkgs.cloud-utils "growpart"} "$out/${config.image.fileName}" 1
      '';
    };

    system.build.image = config.system.build.azureImage;
    system.nixos.tags = [ "azure" ];
  };
}
