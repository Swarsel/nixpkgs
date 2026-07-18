{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.iio-hyprland;
in
{
  options = {
    programs.iio-hyprland = {
      enable = lib.mkEnableOption "iio-hyprland and iio-sensor-proxy";
      package = lib.mkPackageOption pkgs "iio-hyprland" { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    hardware.sensor.iio.enable = lib.mkDefault true;
  };

  meta.maintainers = with lib.maintainers; [ yusuf-duran ];
}
