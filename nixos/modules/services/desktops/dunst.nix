{
  config,
  lib,
  pkgs,
  ...
}:
let
  gitIni = pkgs.formats.gitIni { };
  cfg = config.services.dunst;
in
{
  options.services.dunst = {
    enable = lib.mkEnableOption "Dunst notification daemon";

    package = lib.mkPackageOption pkgs "dunst" { } // {
      apply =
        p:
        p.override {
          withWayland = cfg.enableWayland;
          withX11 = cfg.enableX11;
        };
    };

    enableWayland = lib.mkOption {
      default = true;
      description = "Whether to enable Wayland support.";
      type = lib.types.bool;
    };

    enableX11 = lib.mkOption {
      default = true;
      description = "Whether to enable X11 support.";
      type = lib.types.bool;
    };

    settings = lib.mkOption {
      default = { };
      description = "Dunst configuration, see dunst(5)";

      example = lib.literalExpression ''
        {
          global = {
            width = 300;
            height = 300;
            offset = "30x50";
            origin = "top-right";
            transparency = 10;
            frame_color = "#eceff1";
            font = "Droid Sans 9";
          };

          urgency_normal = {
            background = "#37474f";
            foreground = "#eceff1";
            timeout = 10;
          };
        };
      '';

      type = gitIni.type;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enableX11 || cfg.enableWayland;
        message = "Dunst must be built with at least either X11 support or Wayland support";
      }
    ];

    environment = {
      etc."xdg/dunst/dunstrc".source = gitIni.generate "dunstrc" cfg.settings;
      systemPackages = [ cfg.package ];
    };

    services.dbus.packages = [ cfg.package ];
  };

  meta.maintainers = with lib.maintainers; [ nyukuru ];
}
