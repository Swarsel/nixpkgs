{
  config,
  lib,
  pkgs,
  ...
}:

let

  dmcfg = config.services.displayManager;
  ldmcfg = config.services.xserver.displayManager.lightdm;
  cfg = ldmcfg.greeters.lomiri;

in
{
  options = {
    services.xserver.displayManager.lightdm.greeters.lomiri = {
      enable = lib.mkEnableOption "lomiri's greeter as the lightdm greeter";
    };
  };

  config = lib.mkIf (ldmcfg.enable && cfg.enable) {
    # Lomiri greeter == Lomiri shell in special mode, need some basics setup at least
    services.desktopManager.lomiri.basics = true;

    # Greeter needs to be run through its wrapper
    # Greeter doesn't work with our set-session.py script, need to set default user-session
    services.xserver.displayManager.lightdm.extraSeatDefaults = ''
      greeter-wrapper = ${lib.getExe' pkgs.lomiri.lomiri "lomiri-greeter-wrapper"}
      user-session = ${dmcfg.defaultSession}
    '';

    services.xserver.displayManager.lightdm.greeter = lib.mkDefault {
      package = pkgs.lomiri.lomiri.greeter;
      name = "lomiri-greeter";
    };

    services.xserver.displayManager.lightdm.greeters.gtk.enable = false;
  };

  meta.teams = [ lib.teams.lomiri ];
}
