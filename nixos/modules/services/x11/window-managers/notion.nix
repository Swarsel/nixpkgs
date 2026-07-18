{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.xserver.windowManager.notion;
in

{
  options = {
    services.xserver.windowManager.notion.enable = mkEnableOption "notion";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.notion ];

    services.xserver.windowManager = {
      session = [
        {
          name = "notion";

          start = ''
            ${pkgs.notion}/bin/notion &
            waitPID=$!
          '';
        }
      ];
    };
  };
}
