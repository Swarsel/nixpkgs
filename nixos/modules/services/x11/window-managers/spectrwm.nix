{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.xserver.windowManager.spectrwm;
in

{
  options = {
    services.xserver.windowManager.spectrwm.enable = mkEnableOption "spectrwm";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.spectrwm ];

    services.xserver.windowManager = {
      session = [
        {
          name = "spectrwm";

          start = ''
            ${pkgs.spectrwm}/bin/spectrwm &
            waitPID=$!
          '';
        }
      ];
    };
  };
}
