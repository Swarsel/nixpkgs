{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.digitalbitbox;
in

{
  options.hardware.digitalbitbox = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Enables udev rules for Digital Bitbox devices.
      '';

      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs "digitalbitbox" {
      extraDescription = ''
        This can be used to install a package with udev rules that differ from the defaults.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = [ cfg.package ];
  };
}
