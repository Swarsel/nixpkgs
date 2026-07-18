{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.virtualisation.googleComputeImage;
  defaultConfigFile = pkgs.writeText "configuration.nix" ''
    { ... }:
    {
      imports = [
        <nixpkgs/nixos/modules/virtualisation/google-compute-image.nix>
      ];
    }
  '';
in
{

  imports = [
    ./google-compute-config.nix
    ./disk-size-option.nix
    ../image/file-options.nix
    (lib.mkRenamedOptionModuleWith {
      from = [
        "virtualisation"
        "googleComputeImage"
        "diskSize"
      ];

      sinceRelease = 2411;

      to = [
        "virtualisation"
        "diskSize"
      ];
    })
  ];

  options = {
    virtualisation.googleComputeImage.buildMemSize = mkOption {
      default = 1024;
      description = "Memory size (in MiB) for the temporary VM used to build the image.";
      type = types.int;
    };

    virtualisation.googleComputeImage.compressionLevel = mkOption {
      default = 6;

      description = ''
        GZIP compression level of the resulting disk image (1-9).
      '';

      type = types.int;
    };

    virtualisation.googleComputeImage.configFile = mkOption {
      default = null;

      description = ''
        A path to a configuration file which will be placed at `/etc/nixos/configuration.nix`
        and be used when switching to a new configuration.
        If set to `null`, a default configuration is used, where the only import is
        `<nixpkgs/nixos/modules/virtualisation/google-compute-image.nix>`.
      '';

      type = with types; nullOr str;
    };

    virtualisation.googleComputeImage.contents = mkOption {
      default = [ ];

      description = ''
        The files and directories to be placed in the image.
        This is a list of attribute sets {source, target, mode, user, group} where
        `source' is the file system object (regular file or directory) to be
        grafted in the file system at path `target', `mode' is a string containing
        the permissions that will be set (ex. "755"), `user' and `group' are the
        user and group name that will be set as owner of the files.
        `mode', `user', and `group' are optional.
        When setting one of `user' or `group', the other needs to be set too.
      '';

      example = literalExpression ''
        [
          {
            source = ./default.nix;
            target = "/etc/nixos/default.nix";
            mode = "0644";
            user = "root";
            group = "root";
          }
        ];
      '';

      type = with types; listOf attrs;
    };

    virtualisation.googleComputeImage.efi = mkEnableOption "EFI booting";
  };

  #### implementation
  config = {
    boot.initrd.availableKernelModules = [ "nvme" ];

    boot.loader.grub = mkIf cfg.efi {
      device = mkForce "nodev";
      efiInstallAsRemovable = true;
      efiSupport = true;
    };

    fileSystems."/boot" = mkIf cfg.efi {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };

    image.extension = "raw.tar.gz";

    system.build.googleComputeImage = import ../../lib/make-disk-image.nix {
      inherit (config.image) baseName;
      inherit (cfg) contents;
      inherit (config.virtualisation) diskSize;
      inherit config lib pkgs;
      configFile = if cfg.configFile == null then defaultConfigFile else cfg.configFile;
      format = "raw";
      memSize = cfg.buildMemSize;
      name = "google-compute-image";
      partitionTableType = if cfg.efi then "efi" else "legacy";

      postVM = ''
        PATH=$PATH:${
          with pkgs;
          lib.makeBinPath [
            gnutar
            gzip
          ]
        }
        pushd $out
        # RTFM:
        # https://cloud.google.com/compute/docs/images/create-custom
        # https://cloud.google.com/compute/docs/import/import-existing-image
        mv $diskImage disk.raw
        tar -Sc disk.raw | gzip -${toString cfg.compressionLevel} > \
          ${config.image.fileName}
        rm disk.raw
        popd
      '';
    };

    system.build.image = config.system.build.googleComputeImage;
    system.nixos.tags = [ "google-compute" ];

  };

}
