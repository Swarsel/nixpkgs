{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.hardware.glasgow;

in
{
  options.hardware.glasgow = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Enables Glasgow udev rules and ensures 'plugdev' group exists.
        This is a prerequisite to using Glasgow without being root.
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.glasgow ];
    services.udev.packages = [ pkgs.glasgow ];
    users.groups.plugdev = { };
  };
}
