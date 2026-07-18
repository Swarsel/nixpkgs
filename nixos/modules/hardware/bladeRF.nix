{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.bladeRF;

in

{
  options.hardware.bladeRF = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Enables udev rules for BladeRF devices. By default grants access
        to users in the "bladerf" group. You may want to install the
        libbladeRF package.
      '';

      type = lib.types.bool;
    };

  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = [ pkgs.libbladeRF ];
    users.groups.bladerf = { };
  };
}
