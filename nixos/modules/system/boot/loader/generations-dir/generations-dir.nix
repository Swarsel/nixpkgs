{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  generationsDirBuilder = pkgs.replaceVarsWith {
    isExecutable = true;

    replacements = {
      inherit (pkgs) bash;
      inherit (config.boot.loader.generationsDir) copyKernels;

      path = lib.makeBinPath [
        pkgs.coreutils
        pkgs.gnused
        pkgs.gnugrep
      ];
    };

    src = ./generations-dir-builder.sh;
  };

in

{
  options = {

    boot.loader.generationsDir = {

      enable = mkOption {
        default = false;

        description = ''
          Whether to create symlinks to the system generations under
          `/boot`.  When enabled,
          `/boot/default/kernel`,
          `/boot/default/initrd`, etc., are updated to
          point to the current generation's kernel image, initial RAM
          disk, and other bootstrap files.

          This optional is not necessary with boot loaders such as GNU GRUB
          for which the menu is updated to point to the latest bootstrap
          files.  However, it is needed for U-Boot on platforms where the
          boot command line is stored in flash memory rather than in a
          menu file.
        '';

        type = types.bool;
      };

      copyKernels = mkOption {
        default = false;

        description = ''
          Whether to copy the necessary boot files into /boot, so
          /nix/store is not needed by the boot loader.
        '';

        type = types.bool;
      };

    };

  };

  config = mkIf config.boot.loader.generationsDir.enable {

    system.boot.loader.id = "generationsDir";
    system.build.installBootLoader = generationsDirBuilder;

  };
}
