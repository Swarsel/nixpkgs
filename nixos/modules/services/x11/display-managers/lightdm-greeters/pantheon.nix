{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  dmcfg = config.services.xserver.displayManager;
  ldmcfg = dmcfg.lightdm;
  cfg = ldmcfg.greeters.pantheon;

in
{
  options = {

    services.xserver.displayManager.lightdm.greeters.pantheon = {

      enable = mkOption {
        default = false;

        description = ''
          Whether to enable elementary-greeter as the lightdm greeter.
        '';

        type = types.bool;
      };

    };

  };

  config = mkIf (ldmcfg.enable && cfg.enable) {

    environment.etc."lightdm/io.elementary.greeter.conf".source =
      "${pkgs.pantheon.elementary-greeter}/etc/lightdm/io.elementary.greeter.conf";

    environment.etc."wingpanel.d/io.elementary.greeter.allowed".source =
      "${pkgs.pantheon.elementary-default-settings}/etc/wingpanel.d/io.elementary.greeter.allowed";

    # Show manual login card.
    services.xserver.displayManager.lightdm.extraSeatDefaults = "greeter-show-manual-login=true";

    services.xserver.displayManager.lightdm.greeter = mkDefault {
      package = pkgs.pantheon.elementary-greeter.xgreeters;
      name = "io.elementary.greeter";
    };

    services.xserver.displayManager.lightdm.greeters.gtk.enable = false;

  };

  meta = {
    teams = [ lib.teams.pantheon ];
  };
}
