{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types;

  xcfg = config.services.xserver;
  cfg = xcfg.desktopManager;

  # If desktop manager `d' isn't capable of setting a background and
  # the xserver is enabled, `feh' or `xsetroot' are used as a fallback.
  needBGCond = d: !(d ? bgSupport && d.bgSupport) && xcfg.enable && cfg.wallpaper.enable;

in

{
  # Note: the order in which desktop manager modules are imported here
  # determines the default: later modules (if enabled) are preferred.
  # E.g., if Plasma 5 is enabled, it supersedes xterm.
  imports = [
    ./none.nix
    ./xterm.nix
    ./phosh.nix
    ./xfce.nix
    ../../desktop-managers/plasma6.nix
    ./lumina.nix
    ./lxqt.nix
    ./enlightenment.nix
    ./retroarch.nix
    ./kodi.nix
    ./mate.nix
    ../../desktop-managers/pantheon.nix
    ./surf-display.nix
    ./cde.nix
    ./cinnamon.nix
    ../../desktop-managers/budgie.nix
    ../../desktop-managers/lomiri.nix
    ../../desktop-managers/cosmic.nix
    ../../desktop-managers/gnome.nix
  ];

  options = {

    services.xserver.desktopManager = {

      session = mkOption {
        apply = map (
          d:
          d
          // {
            manage = "desktop";

            start =
              d.start
              # literal newline to ensure d.start's last line is not appended to
              + lib.optionalString (needBGCond d) ''

                if [ -e $HOME/.background-image ]; then
                  ${pkgs.feh}/bin/feh --bg-${cfg.wallpaper.mode} ${lib.optionalString cfg.wallpaper.combineScreens "--no-xinerama"} $HOME/.background-image
                fi
              '';
          }
        );

        default = [ ];

        description = ''
          Internal option used to add some common line to desktop manager
          scripts before forwarding the value to the
          `displayManager`.
        '';

        example = lib.singleton {
          bgSupport = true;
          name = "kde";
          start = "...";
        };

        internal = true;
      };

      wallpaper = {
        enable = mkOption {
          default = true;

          description = ''
            The file {file}`~/.background-image` is used as a background image.
            The `mode` option specifies the placement of this image onto your desktop.
            To disable this, set this option to `false`.
          '';

          type = types.bool;
        };

        combineScreens = mkOption {
          default = false;

          description = ''
            When set to `true` the wallpaper will stretch across all screens.
            When set to `false` the wallpaper is duplicated to all screens.
          '';

          type = types.bool;
        };

        mode = mkOption {
          default = "scale";

          description = ''
            Possible values:
            `center`: Center the image on the background. If it is too small, it will be surrounded by a black border.
            `fill`: Like `scale`, but preserves aspect ratio by zooming the image until it fits. Either a horizontal or a vertical part of the image will be cut off.
            `max`: Like `fill`, but scale the image to the maximum size that fits the screen with black borders on one side.
            `scale`: Fit the file into the background without repeating it, cutting off stuff or using borders. But the aspect ratio is not preserved either.
            `tile`: Tile (repeat) the image in case it is too small for the screen.
          '';

          example = "fill";

          type = types.enum [
            "center"
            "fill"
            "max"
            "scale"
            "tile"
          ];
        };
      };

    };

  };

  config.services.xserver.displayManager.session = cfg.session;
}
