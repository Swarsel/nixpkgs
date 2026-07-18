{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.xserver.windowManager.sawfish;
in
{
  ###### interface
  options = {
    services.xserver.windowManager.sawfish.enable = mkEnableOption "sawfish";
  };

  ###### implementation
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.sawfish ];

    services.xserver.windowManager.session = singleton {
      name = "sawfish";

      start = ''
        ${pkgs.sawfish}/bin/sawfish &
        waitPID=$!
      '';
    };
  };
}
