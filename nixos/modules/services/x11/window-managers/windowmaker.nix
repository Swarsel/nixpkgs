{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.xserver.windowManager.windowmaker;
in
{
  ###### interface
  options = {
    services.xserver.windowManager.windowmaker.enable = mkEnableOption "windowmaker";
  };

  ###### implementation
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.windowmaker ];

    services.xserver.windowManager.session = singleton {
      name = "windowmaker";

      start = ''
        ${pkgs.windowmaker}/bin/wmaker &
        waitPID=$!
      '';
    };
  };
}
