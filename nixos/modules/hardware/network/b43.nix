{
  config,
  lib,
  pkgs,
  ...
}:
let
  kernelVersion = config.boot.kernelPackages.kernel.version;
in

{

  ###### interface

  options = {

    networking.enableB43Firmware = lib.mkOption {
      default = false;

      description = ''
        Turn on this option if you want firmware for the NICs supported by the b43 module.
      '';

      type = lib.types.bool;
    };

  };

  ###### implementation

  config = lib.mkIf config.networking.enableB43Firmware {
    hardware.firmware = [ pkgs.b43Firmware_5_1_138 ];
  };

}
