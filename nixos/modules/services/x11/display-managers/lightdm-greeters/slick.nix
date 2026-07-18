{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  ldmcfg = config.services.xserver.displayManager.lightdm;
  cfg = ldmcfg.greeters.slick;

  inherit (pkgs) writeText;

  theme = cfg.theme.package;
  icons = cfg.iconTheme.package;
  font = cfg.font.package;
  cursors = cfg.cursorTheme.package;

  slickGreeterConf = writeText "slick-greeter.conf" ''
    [Greeter]
    background=${ldmcfg.background}
    theme-name=${cfg.theme.name}
    icon-theme-name=${cfg.iconTheme.name}
    font-name=${cfg.font.name}
    cursor-theme-name=${cfg.cursorTheme.name}
    cursor-theme-size=${toString cfg.cursorTheme.size}
    draw-user-backgrounds=${boolToString cfg.draw-user-backgrounds}
    ${cfg.extraConfig}
  '';
in
{
  options = {
    services.xserver.displayManager.lightdm.greeters.slick = {
      enable = mkEnableOption "lightdm-slick-greeter as the lightdm greeter";

      cursorTheme = {
        package = mkPackageOption pkgs "adwaita-icon-theme" { };

        name = mkOption {
          default = "Adwaita";

          description = ''
            Name of the cursor theme to use for the lightdm-slick-greeter.
          '';

          type = types.str;
        };

        size = mkOption {
          default = 24;

          description = ''
            Size of the cursor theme to use for the lightdm-slick-greeter.
          '';

          type = types.int;
        };
      };

      draw-user-backgrounds = mkEnableOption "draw user backgrounds";

      extraConfig = mkOption {
        default = "";

        description = ''
          Extra configuration that should be put in the lightdm-slick-greeter.conf
          configuration file.
        '';

        type = types.lines;
      };

      font = {
        package = mkPackageOption pkgs "ubuntu-classic" { };

        name = mkOption {
          default = "Ubuntu 11";

          description = ''
            Name of the font to use.
          '';

          type = types.str;
        };
      };

      iconTheme = {
        package = mkPackageOption pkgs "adwaita-icon-theme" { };

        name = mkOption {
          default = "Adwaita";

          description = ''
            Name of the icon theme to use for the lightdm-slick-greeter.
          '';

          type = types.str;
        };
      };

      theme = {
        package = mkPackageOption pkgs "gnome-themes-extra" { };

        name = mkOption {
          default = "Adwaita";

          description = ''
            Name of the theme to use for the lightdm-slick-greeter.
          '';

          type = types.str;
        };
      };
    };
  };

  config = mkIf (ldmcfg.enable && cfg.enable) {
    environment.etc."lightdm/slick-greeter.conf".source = slickGreeterConf;

    environment.systemPackages = [
      cursors
      icons
      theme
    ];

    fonts.packages = [ font ];

    services.xserver.displayManager.lightdm = {
      greeter = mkDefault {
        package = pkgs.lightdm-slick-greeter.xgreeters;
        name = "lightdm-slick-greeter";
      };

      greeters.gtk.enable = false;
    };
  };
}
