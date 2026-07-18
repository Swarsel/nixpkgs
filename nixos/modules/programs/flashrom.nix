{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.flashrom;
in
{
  options.programs.flashrom = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Installs flashrom and configures udev rules for programmers
        used by flashrom. Grants access to users in the "flashrom"
        group.
      '';

      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs "flashrom" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    services.udev.packages = [ cfg.package ];
  };
}
