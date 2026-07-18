{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.xserver.windowManager.oxwm;
in
{
  options.services.xserver.windowManager.oxwm = {
    enable = lib.mkEnableOption "oxwm";
    package = lib.mkPackageOption pkgs "oxwm" { };
  };

  config = lib.mkIf cfg.enable {
    environment.pathsToLink = [
      "/share/oxwm"
      "/share/xsessions"
    ];

    environment.systemPackages = [ cfg.package ];
    services.displayManager.sessionPackages = [ cfg.package ];
  };
}
