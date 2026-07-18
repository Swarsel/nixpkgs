{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.hardware.kryoflux;

in
{
  options.hardware.kryoflux = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Enables kryoflux udev rules, ensures 'floppy' group exists. This is a
        prerequisite to using devices supported by kryoflux without being root,
        since kryoflux device descriptors will be owned by floppy through udev.
      '';

      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs "kryoflux" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    services.udev.packages = [ cfg.package ];
    users.groups.floppy = { };
  };

  meta.maintainers = with lib.maintainers; [ matthewcroughan ];
}
