{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.xserver.windowManager.windowlab;
in

{
  options = {
    services.xserver.windowManager.windowlab.enable = lib.mkEnableOption "windowlab";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.windowlab ];

    services.xserver.windowManager = {
      session = [
        {
          name = "windowlab";
          start = "${pkgs.windowlab}/bin/windowlab";
        }
      ];
    };
  };
}
