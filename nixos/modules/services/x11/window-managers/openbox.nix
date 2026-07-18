{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.xserver.windowManager.openbox;
in

{
  options = {
    services.xserver.windowManager.openbox.enable = mkEnableOption "openbox";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.openbox ];

    services.xserver.windowManager = {
      session = [
        {
          name = "openbox";

          start = "
          ${pkgs.openbox}/bin/openbox-session
        ";
        }
      ];
    };
  };
}
