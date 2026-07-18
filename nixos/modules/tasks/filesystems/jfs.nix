{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  inInitrd = config.boot.initrd.supportedFilesystems.jfs or false;
in
{
  config = mkIf (config.boot.supportedFilesystems.jfs or false) {

    boot.initrd.extraUtilsCommands = mkIf (inInitrd && !config.boot.initrd.systemd.enable) ''
      copy_bin_and_libs ${lib.getBin pkgs.jfsutils}/sbin/fsck.jfs
    '';

    boot.initrd.kernelModules = mkIf inInitrd [ "jfs" ];
    boot.initrd.systemd.initrdBin = mkIf inInitrd [ pkgs.jfsutils ];
    system.fsPackages = [ pkgs.jfsutils ];
  };
}
