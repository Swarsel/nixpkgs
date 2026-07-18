{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

with lib;

let

  xcfg = config.services.xserver;
  cfg = xcfg.desktopManager.mate;

in

{
  options = {

    environment.mate.excludePackages = mkOption {
      default = [ ];
      description = "Which MATE packages to exclude from the default environment";
      example = literalExpression "[ pkgs.mate-terminal pkgs.pluma ]";
      type = types.listOf types.package;
    };

    services.xserver.desktopManager.mate = {
      enable = mkOption {
        default = false;
        description = "Enable the MATE desktop environment";
        type = types.bool;
      };

      debug = mkEnableOption "mate-session debug messages";
      enableWaylandSession = mkEnableOption "MATE Wayland session";

      extraCajaExtensions = mkOption {
        default = [ ];
        description = "Extra extensions to add to caja.";
        example = lib.literalExpression "with pkgs; [ caja-extensions ]";
        type = types.listOf types.package;
      };

      extraPanelApplets = mkOption {
        default = [ ];
        description = "Extra applets to add to mate-panel.";
        example = literalExpression "with pkgs; [ mate-applets ]";
        type = types.listOf types.package;
      };
    };

  };

  config = mkMerge [
    (mkIf (cfg.enable || cfg.enableWaylandSession) {
      environment.extraInit = lib.optionalString config.services.gnome.gcr-ssh-agent.enable ''
        # Hack: https://bugzilla.redhat.com/show_bug.cgi?id=2250704 still
        # applies to sessions not managed by systemd.
        if [ -z "$SSH_AUTH_SOCK" ] && [ -n "$XDG_RUNTIME_DIR" ]; then
          export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"
        fi
      '';

      environment.pathsToLink = [ "/share" ];
      # Debugging
      environment.sessionVariables.MATE_SESSION_DEBUG = mkIf cfg.debug "1";

      environment.systemPackages = utils.removePackagesByName (with pkgs; [
        # Base packages.
        libmatekbd
        libmatemixer
        libmateweather
        marco
        mate-common
        mate-control-center
        mate-desktop
        mate-icon-theme
        mate-menus
        mate-notification-daemon
        mate-polkit
        mate-session-manager
        mate-settings-daemon
        mate-settings-daemon-wrapped
        mate-themes

        # Extra packages.
        atril
        caja-extensions # for caja-sendto
        engrampa
        eom
        mate-applets
        mate-backgrounds
        mate-calc
        mate-indicator-applet
        mate-media
        mate-netbook
        mate-power-manager
        mate-screensaver
        mate-system-monitor
        mate-terminal
        mate-user-guide
        # mate-user-share
        mate-utils
        mozo
        pluma

        (caja-with-extensions.override {
          extensions = cfg.extraCajaExtensions;
        })
        (mate-panel-with-applets.override {
          applets = cfg.extraPanelApplets;
        })
        desktop-file-utils
        glib
        gtk3.out
        shared-mime-info
        xdg-user-dirs # Update user dirs as described in https://freedesktop.org/wiki/Software/xdg-user-dirs/
        yelp # for 'Contents' in 'Help' menus
      ]) config.environment.mate.excludePackages;

      # Shell integration for VTE terminals
      programs.bash.vteIntegration = mkDefault true;
      programs.dconf.enable = true;
      # Mate uses this for printing
      programs.system-config-printer.enable = (mkIf config.services.printing.enable (mkDefault true));
      programs.zsh.vteIntegration = mkDefault true;
      security.pam.services.mate-screensaver.unixAuth = true;

      security.polkit = {
        enable = true;
        enablePkexecWrapper = mkDefault true;
      };

      services.displayManager.sessionPackages = [
        pkgs.mate-session-manager
      ];

      services.gnome.at-spi2-core.enable = true;
      services.gnome.gcr-ssh-agent.enable = mkDefault true;
      services.gnome.glib-networking.enable = true;
      services.gnome.gnome-keyring.enable = true;
      services.gvfs.enable = true;
      services.libinput.enable = mkDefault true;
      services.udev.packages = [ pkgs.mate-settings-daemon ];
      services.upower.enable = config.powerManagement.enable;
      xdg.portal.configPackages = mkDefault [ pkgs.mate-desktop ];
    })
    (mkIf cfg.enableWaylandSession {
      environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR = "${pkgs.mate-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas";
      environment.systemPackages = [ pkgs.mate-wayland-session ];
      programs.wayfire.enable = true;
      services.displayManager.sessionPackages = [ pkgs.mate-wayland-session ];
    })
  ];
}
