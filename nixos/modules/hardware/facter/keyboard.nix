{ config, lib, ... }:
let
  facterLib = import ./lib.nix lib;

  inherit (config.hardware.facter) report;
in
{
  options.hardware.facter.detected.boot.keyboard.kernelModules = lib.mkOption {
    default = lib.uniqueStrings (facterLib.collectDrivers (report.hardware.usb_controller or [ ]));
    defaultText = "hardware dependent";

    description = ''
      List of kernel modules to include in the initrd to support the keyboard.
    '';

    example = [ "usbhid" ];
    type = lib.types.listOf lib.types.str;
  };

  config = lib.mkIf config.hardware.facter.enable {
    boot.initrd.availableKernelModules = config.hardware.facter.detected.boot.keyboard.kernelModules;
  };
}
