{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.programs.hamster.enable = lib.mkEnableOption "hamster, a time tracking program";

  config = lib.mkIf config.programs.hamster.enable {
    environment.systemPackages = [ pkgs.hamster ];
    services.dbus.packages = [ pkgs.hamster ];
  };

  meta.maintainers = pkgs.hamster.meta.maintainers;
}
