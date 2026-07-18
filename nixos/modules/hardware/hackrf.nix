{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.hardware.hackrf;

in
{
  options.hardware.hackrf = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Enables hackrf udev rules and ensures 'plugdev' group exists.
        This is a prerequisite to using HackRF devices without being root, since HackRF USB descriptors will be owned by plugdev through udev.
        Ensure your user is a member of the 'plugdev' group after enabling.
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = [ pkgs.hackrf ];
    users.groups.plugdev = { };
  };
}
