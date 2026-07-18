{
  config,
  lib,
  pkgs,
  ...
}:

{

  ###### interface

  options = {

    networking.enableIntel2200BGFirmware = lib.mkOption {
      default = false;

      description = ''
        Turn on this option if you want firmware for the Intel
        PRO/Wireless 2200BG to be loaded automatically.  This is
        required if you want to use this device.
      '';

      type = lib.types.bool;
    };

  };

  ###### implementation

  config = lib.mkIf config.networking.enableIntel2200BGFirmware {

    hardware.firmware = [ pkgs.ipw2200-firmware ];

  };

}
