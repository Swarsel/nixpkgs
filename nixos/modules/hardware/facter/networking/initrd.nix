{ config, lib, ... }:
let
  facterLib = import ../lib.nix lib;

  inherit (config.hardware.facter) report;
in
{
  options.hardware.facter.detected.boot.initrd.networking.kernelModules = lib.mkOption {
    default = lib.uniqueStrings (facterLib.collectDrivers (report.hardware.network_controller or [ ]));
    defaultText = "hardware dependent";

    description = ''
      List of kernel modules to include in the initrd to support networking.
    '';

    type = lib.types.listOf lib.types.str;
  };

  config = lib.mkIf (config.hardware.facter.enable && config.boot.initrd.network.enable) {
    boot.initrd.kernelModules = config.hardware.facter.detected.boot.initrd.networking.kernelModules;
  };
}
