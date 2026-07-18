{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.xserver.windowManager.lwm;
in
{
  ###### interface
  options = {
    services.xserver.windowManager.lwm.enable = mkEnableOption "lwm";
  };

  ###### implementation
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.lwm ];

    services.xserver.windowManager.session = singleton {
      name = "lwm";

      start = ''
        ${pkgs.lwm}/bin/lwm &
        waitPID=$!
      '';
    };
  };
}
