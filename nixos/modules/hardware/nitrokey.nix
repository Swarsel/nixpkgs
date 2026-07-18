{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.hardware.nitrokey;

in

{
  options.hardware.nitrokey = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Enables udev rules for Nitrokey devices.
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = [ pkgs.nitrokey-udev-rules ];
  };
}
