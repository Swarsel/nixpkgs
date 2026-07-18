{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  inInitrd = config.boot.initrd.supportedFilesystems.apfs or false;

in

{
  config = mkIf (config.boot.supportedFilesystems.apfs or false) {

    boot.extraModulePackages = [ config.boot.kernelPackages.apfs ];
    boot.initrd.kernelModules = mkIf inInitrd [ "apfs" ];
    system.fsPackages = [ pkgs.apfsprogs ];
    # Don't copy apfsck into the initramfs since it does not support repairing the filesystem
  };
}
