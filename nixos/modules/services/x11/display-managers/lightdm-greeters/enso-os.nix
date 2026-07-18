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
  cfg = ldmcfg.greeters.enso;

  theme = cfg.theme.package;
  icons = cfg.iconTheme.package;
  cursors = cfg.cursorTheme.package;

  ensoGreeterConf = pkgs.writeText "lightdm-enso-os-greeter.conf" ''
    [greeter]
    default-wallpaper=${ldmcfg.background}
    gtk-theme=${cfg.theme.name}
    icon-theme=${cfg.iconTheme.name}
    cursor-theme=${cfg.cursorTheme.name}
    blur=${toString cfg.blur}
    brightness=${toString cfg.brightness}
    ${cfg.extraConfig}
  '';
in
{
  options = {
    services.xserver.displayManager.lightdm.greeters.enso = {
      enable = mkOption {
        default = false;

        description = ''
          Whether to enable enso-os-greeter as the lightdm greeter
        '';

        type = types.bool;
      };

      blur = mkOption {
        default = false;

        description = ''
          Whether or not to enable blur
        '';

        type = types.bool;
      };

      brightness = mkOption {
        default = 7;

        description = ''
          Brightness
        '';

        type = types.int;
      };

      cursorTheme = {
        package = mkPackageOption pkgs "capitaine-cursors" { };

        name = mkOption {
          default = "capitane-cursors";

          description = ''
            Name of the cursor theme to use for the lightdm-enso-os-greeter
          '';

          type = types.str;
        };
      };

      extraConfig = mkOption {
        default = "";

        description = ''
          Extra configuration that should be put in the greeter.conf
          configuration file
        '';

        type = types.lines;
      };

      iconTheme = {
        package = mkPackageOption pkgs "papirus-icon-theme" { };

        name = mkOption {
          default = "ePapirus";

          description = ''
            Name of the icon theme to use for the lightdm-enso-os-greeter
          '';

          type = types.str;
        };
      };

      theme = {
        package = mkPackageOption pkgs "gnome-themes-extra" { };

        name = mkOption {
          default = "Adwaita";

          description = ''
            Name of the theme to use for the lightdm-enso-os-greeter
          '';

          type = types.str;
        };
      };
    };
  };

  config = mkIf (ldmcfg.enable && cfg.enable) {
    environment.etc."lightdm/greeter.conf".source = ensoGreeterConf;

    environment.systemPackages = [
      cursors
      icons
      theme
    ];

    services.xserver.displayManager.lightdm = {
      greeter = mkDefault {
        package = pkgs.lightdm-enso-os-greeter.xgreeters;
        name = "pantheon-greeter";
      };

      greeters = {
        gtk = {
          enable = mkDefault false;
        };
      };
    };
  };
}
