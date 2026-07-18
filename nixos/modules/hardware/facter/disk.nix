{ config, lib, ... }:
let
  facterLib = import ./lib.nix lib;

  inherit (config.hardware.facter) report;
in
{
  options.hardware.facter.detected.boot.disk.kernelModules = lib.mkOption {
    default = lib.uniqueStrings (
      facterLib.collectDrivers (
        # A disk might be attached.
        (report.hardware.firewire_controller or [ ])
        # definitely important
        ++ (report.hardware.disk or [ ])
        ++ (report.hardware.storage_controller or [ ])
      )
    );

    defaultText = "hardware dependent";

    description = ''
      List of kernel modules that are needed to access the disk.
    '';

    type = lib.types.listOf lib.types.str;
  };

  config = lib.mkIf config.hardware.facter.enable {
    boot.initrd.availableKernelModules = config.hardware.facter.detected.boot.disk.kernelModules;
  };
}
