{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.dwl;
in
{
  options.programs.dwl = {
    enable = lib.mkEnableOption ''
      Dwl is a compact, hackable compositor for Wayland based on wlroots.
      You can manually launch Dwl by executing "exec dwl" on a TTY.
    '';

    package = lib.mkPackageOption pkgs "dwl" {
      example = ''
        # Lets apply bar patch from:
        # https://codeberg.org/dwl/dwl-patches/src/branch/main/patches/bar
        (pkgs.dwl.override {
          configH = ./dwl-config.h;
        }).overrideAttrs (oldAttrs: {
          buildInputs =
            oldAttrs.buildInputs or []
            ++ [
              pkgs.libdrm
              pkgs.fcft
            ];
          patches = oldAttrs.patches or [] ++ [
            ./bar-0.7.patch
          ];
        });
      '';
    };

    extraSessionCommands = lib.mkOption {
      default = "";

      description = ''
        Shell commands executed just before dwl is started.
      '';

      type = lib.types.lines;
    };
  };

  config = lib.mkIf cfg.enable {
    # Create wrapper script for dwl
    environment.etc."xdg/dwl-session" = {
      mode = "0755"; # Make it executable

      text = ''
        #!${pkgs.runtimeShell}
        # Import environment variables
        ${cfg.extraSessionCommands}
        # Setup systemd user environment
        systemctl --user import-environment DISPLAY WAYLAND_DISPLAY
        systemctl --user start dwl-session.target
        # Start dwl
        exec ${lib.getExe cfg.package}
      '';
    };

    environment.systemPackages = [ cfg.package ];

    # Create desktop entry for display managers
    services.displayManager.sessionPackages =
      let
        dwlDesktopFile = pkgs.writeTextFile {
          destination = "/share/wayland-sessions/dwl.desktop";
          name = "dwl-desktop-entry";

          text = ''
            [Desktop Entry]
            Name=dwl
            Comment=Dynamic window manager for Wayland
            Exec=/etc/xdg/dwl-session
            Type=Application
          '';
        };

        dwlSession = pkgs.symlinkJoin {
          name = "dwl-session";
          passthru.providedSessions = [ "dwl" ];
          paths = [ dwlDesktopFile ];
        };
      in
      [ dwlSession ];

    # Create systemd target for dwl session
    systemd.user.targets.dwl-session = {
      after = [ "graphical-session-pre.target" ];
      bindsTo = [ "graphical-session.target" ];
      description = "dwl compositor session";
      documentation = [ "man:systemd.special(7)" ];
      wants = [ "graphical-session-pre.target" ];
    };

    # Configure XDG portal for dwl (minimal configuration)
    xdg.portal.config.dwl.default = lib.mkDefault [
      "wlr"
      "gtk"
    ];
  };

  meta.maintainers = with lib.maintainers; [ gurjaka ];
}
