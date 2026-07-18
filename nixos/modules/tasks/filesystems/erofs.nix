{
  config,
  lib,
  pkgs,
  ...
}:

let

  inInitrd = config.boot.initrd.supportedFilesystems.erofs or false;
  inSystem = config.boot.supportedFilesystems.erofs or false;

in

{
  config = lib.mkIf (inInitrd || inSystem) {

    boot.initrd.availableKernelModules = lib.mkIf inInitrd [ "erofs" ];
    system.fsPackages = [ pkgs.erofs-utils ];
    # fsck.erofs is currently experimental and should not be run as a
    # privileged user. Thus, it is not included in the initrd.

  };
}
