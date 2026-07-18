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
  cfg = ldmcfg.greeters.tiny;

in
{
  options = {

    services.xserver.displayManager.lightdm.greeters.tiny = {

      enable = mkOption {
        default = false;

        description = ''
          Whether to enable lightdm-tiny-greeter as the lightdm greeter.

          Note that this greeter starts only the default X session.
          You can configure the default X session using
          [](#opt-services.displayManager.defaultSession).
        '';

        type = types.bool;
      };

      extraConfig = mkOption {
        default = "";

        description = ''
          Section to describe style and ui.
        '';

        type = types.lines;
      };

      label = {
        pass = mkOption {
          default = "Password";

          description = ''
            The string to represent the pass_text label.
          '';

          type = types.str;
        };

        user = mkOption {
          default = "Username";

          description = ''
            The string to represent the user_text label.
          '';

          type = types.str;
        };
      };

    };

  };

  config = mkIf (ldmcfg.enable && cfg.enable) {

    assertions = [
      {
        assertion = dmcfg.defaultSession != null;

        message = ''
          Please set: services.displayManager.defaultSession
        '';
      }
    ];

    services.xserver.displayManager.lightdm.greeter =
      let
        configHeader = ''
          #include <gtk/gtk.h>
          static const char *user_text = "${cfg.label.user}";
          static const char *pass_text = "${cfg.label.pass}";
          static const char *session = "${dmcfg.defaultSession}";
        '';
        config = optionalString (cfg.extraConfig != "") (configHeader + cfg.extraConfig);
        package = pkgs.lightdm-tiny-greeter.override { conf = config; };
      in
      mkDefault {
        package = package.xgreeters;
        name = "lightdm-tiny-greeter";
      };

    services.xserver.displayManager.lightdm.greeters.gtk.enable = false;

  };
}
