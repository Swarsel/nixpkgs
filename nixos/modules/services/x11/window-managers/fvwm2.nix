{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.xserver.windowManager.fvwm2;
  fvwm2 = pkgs.fvwm2.override { enableGestures = cfg.gestures; };
in

{

  imports = [
    (mkRenamedOptionModule
      [ "services" "xserver" "windowManager" "fvwm" ]
      [ "services" "xserver" "windowManager" "fvwm2" ]
    )
  ];

  ###### interface

  options = {
    services.xserver.windowManager.fvwm2 = {
      enable = mkEnableOption "Fvwm2 window manager";

      gestures = mkOption {
        default = false;
        description = "Whether or not to enable libstroke for gesture support";
        type = types.bool;
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    environment.systemPackages = [ fvwm2 ];

    services.xserver.windowManager.session = singleton {
      name = "fvwm2";

      start = ''
        ${fvwm2}/bin/fvwm &
        waitPID=$!
      '';
    };
  };
}
