{
  config,
  lib,
  pkgs,
  ...
}:
let
  ntfsEnabled = config.boot.supportedFilesystems.ntfs or false;
  ntfs3gEnabled = config.boot.supportedFilesystems.ntfs-3g or false;
  ntfsPlusSupported = config.boot.kernelPackages.kernelAtLeast "7.1";
  initrdSupport = config.boot.initrd.supportedFilesystems.ntfs or false;
in
{
  config = lib.mkMerge [
    (lib.mkIf (ntfsEnabled && ntfsPlusSupported && !ntfs3gEnabled) {
      boot.initrd.availableKernelModules = lib.optionals initrdSupport [ "ntfs" ];
      system.fsPackages = [ pkgs.ntfsprogs-plus ];
    })

    (lib.mkIf (ntfs3gEnabled || (ntfsEnabled && !ntfsPlusSupported)) {
      boot.initrd.availableKernelModules = lib.optionals initrdSupport [ "ntfs3" ];
      system.fsPackages = [ pkgs.ntfs3g ];
    })
  ];
}
