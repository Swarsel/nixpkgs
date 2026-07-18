{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.xserver.windowManager.mlvwm;

in
{

  options.services.xserver.windowManager.mlvwm = {
    enable = mkEnableOption "Macintosh-like Virtual Window Manager";

    configFile = mkOption {
      default = null;

      description = ''
        Path to the mlvwm configuration file.
        If left at the default value, $HOME/.mlvwmrc will be used.
      '';

      type = with types; nullOr path;
    };
  };

  config = mkIf cfg.enable {

    environment.etc."mlvwm/mlvwmrc" = mkIf (cfg.configFile != null) {
      source = cfg.configFile;
    };

    environment.systemPackages = [ pkgs.mlvwm ];

    services.xserver.windowManager.session = [
      {
        name = "mlvwm";

        start = ''
          ${pkgs.mlvwm}/bin/mlvwm ${optionalString (cfg.configFile != null) "-f /etc/mlvwm/mlvwmrc"} &
          waitPID=$!
        '';
      }
    ];
  };
}
