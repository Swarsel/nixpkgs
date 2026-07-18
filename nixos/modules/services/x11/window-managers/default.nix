{ config, lib, ... }:

let
  inherit (lib) mkOption;
  cfg = config.services.xserver.windowManager;
in

{
  imports = [
    ./2bwm.nix
    ./afterstep.nix
    ./berry.nix
    ./bspwm.nix
    ./cwm.nix
    ./clfswm.nix
    ./dk.nix
    ./dwm.nix
    ./e16.nix
    ./evilwm.nix
    ./exwm.nix
    ./fluxbox.nix
    ./fvwm2.nix
    ./fvwm3.nix
    ./hackedbox.nix
    ./herbstluftwm.nix
    ./hypr.nix
    ./i3.nix
    ./jwm.nix
    ./leftwm.nix
    ./lwm.nix
    ./metacity.nix
    ./mlvwm.nix
    ./mwm.nix
    ./openbox.nix
    ./pekwm.nix
    ./notion.nix
    ./ratpoison.nix
    ./sawfish.nix
    ./smallwm.nix
    ./stumpwm.nix
    ./spectrwm.nix
    ./tinywm.nix
    ./twm.nix
    ./windowmaker.nix
    ./wmderland.nix
    ./wmii.nix
    ./xmonad.nix
    ./qtile.nix
    ./none.nix
  ];

  options = {

    services.xserver.windowManager = {

      session = mkOption {
        apply = map (
          d:
          d
          // {
            manage = "window";
          }
        );

        default = [ ];

        description = ''
          Internal option used to add some common line to window manager
          scripts before forwarding the value to the
          `displayManager`.
        '';

        example = [
          {
            name = "wmii";
            start = "...";
          }
        ];

        internal = true;
      };

    };

  };

  config = {
    services.xserver.displayManager.session = cfg.session;
  };
}
