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
  xcfg = config.services.xserver;
  cfg = ldmcfg.greeters.gtk;

  inherit (pkgs) writeText;

  theme = cfg.theme.package;
  icons = cfg.iconTheme.package;
  cursors = cfg.cursorTheme.package;

  gtkGreeterConf = writeText "lightdm-gtk-greeter.conf" ''
    [greeter]
    theme-name = ${cfg.theme.name}
    icon-theme-name = ${cfg.iconTheme.name}
    cursor-theme-name = ${cfg.cursorTheme.name}
    cursor-theme-size = ${toString cfg.cursorTheme.size}
    background = ${ldmcfg.background}
    ${optionalString (cfg.clock-format != null) "clock-format = ${cfg.clock-format}"}
    ${optionalString (cfg.indicators != null) "indicators = ${concatStringsSep ";" cfg.indicators}"}
    ${optionalString (xcfg.dpi != null) "xft-dpi=${toString xcfg.dpi}"}
    ${cfg.extraConfig}
  '';

in
{
  options = {

    services.xserver.displayManager.lightdm.greeters.gtk = {

      enable = mkOption {
        default = true;

        description = ''
          Whether to enable lightdm-gtk-greeter as the lightdm greeter.
        '';

        type = types.bool;
      };

      clock-format = mkOption {
        default = null;

        description = ''
          Clock format string (as expected by strftime, e.g. "%H:%M")
          to use with the lightdm gtk greeter panel.

          If set to null the default clock format is used.
        '';

        example = "%F";
        type = types.nullOr types.str;
      };

      cursorTheme = {

        package = mkPackageOption pkgs "adwaita-icon-theme" { };

        name = mkOption {
          default = "Adwaita";

          description = ''
            Name of the cursor theme to use for the lightdm-gtk-greeter.
          '';

          type = types.str;
        };

        size = mkOption {
          default = 16;

          description = ''
            Size of the cursor theme to use for the lightdm-gtk-greeter.
          '';

          type = types.int;
        };
      };

      extraConfig = mkOption {
        default = "";

        description = ''
          Extra configuration that should be put in the lightdm-gtk-greeter.conf
          configuration file.
        '';

        type = types.lines;
      };

      iconTheme = {

        package = mkPackageOption pkgs "adwaita-icon-theme" { };

        name = mkOption {
          default = "Adwaita";

          description = ''
            Name of the icon theme to use for the lightdm-gtk-greeter.
          '';

          type = types.str;
        };

      };

      indicators = mkOption {
        default = null;

        description = ''
          List of allowed indicator modules to use for the lightdm gtk
          greeter panel.

          Built-in indicators include "~a11y", "~language", "~session",
          "~power", "~clock", "~host", "~spacer". Unity indicators can be
          represented by short name (e.g. "sound", "power"), service file name,
          or absolute path.

          If set to null the default indicators are used.
        '';

        example = [
          "~host"
          "~spacer"
          "~clock"
          "~spacer"
          "~session"
          "~language"
          "~a11y"
          "~power"
        ];

        type = types.nullOr (types.listOf types.str);
      };

      theme = {

        package = mkPackageOption pkgs "gnome-themes-extra" { };

        name = mkOption {
          default = "Adwaita";

          description = ''
            Name of the theme to use for the lightdm-gtk-greeter.
          '';

          type = types.str;
        };

      };

    };

  };

  config = mkIf (ldmcfg.enable && cfg.enable) {

    environment.etc."lightdm/lightdm-gtk-greeter.conf".source = gtkGreeterConf;

    environment.systemPackages = [
      cursors
      icons
      theme
    ];

    services.xserver.displayManager.lightdm.greeter = mkDefault {
      package = pkgs.lightdm-gtk-greeter.xgreeters;
      name = "lightdm-gtk-greeter";
    };

  };
}
