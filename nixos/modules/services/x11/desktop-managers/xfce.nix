{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

with lib;

let
  cfg = config.services.xserver.desktopManager.xfce;
  excludePackages = config.environment.xfce.excludePackages;

in
{
  imports = [
    # added 2019-08-18
    # needed to preserve some semblance of UI familarity
    # with original XFCE module
    (mkRenamedOptionModule
      [ "services" "xserver" "desktopManager" "xfce4-14" "extraSessionCommands" ]
      [ "services" "xserver" "displayManager" "sessionCommands" ]
    )

    # added 2019-11-04
    # xfce4-14 module removed and promoted to xfce.
    # Needed for configs that used xfce4-14 module to migrate to this one.
    (mkRenamedOptionModule
      [ "services" "xserver" "desktopManager" "xfce4-14" "enable" ]
      [ "services" "xserver" "desktopManager" "xfce" "enable" ]
    )
    (mkRenamedOptionModule
      [ "services" "xserver" "desktopManager" "xfce4-14" "noDesktop" ]
      [ "services" "xserver" "desktopManager" "xfce" "noDesktop" ]
    )
    (mkRenamedOptionModule
      [ "services" "xserver" "desktopManager" "xfce4-14" "enableXfwm" ]
      [ "services" "xserver" "desktopManager" "xfce" "enableXfwm" ]
    )
    (mkRenamedOptionModule
      [ "services" "xserver" "desktopManager" "xfce" "extraSessionCommands" ]
      [ "services" "xserver" "displayManager" "sessionCommands" ]
    )
    (mkRemovedOptionModule [ "services" "xserver" "desktopManager" "xfce" "screenLock" ] "")

    # added 2022-06-26
    # thunar has its own module
    (mkRenamedOptionModule
      [ "services" "xserver" "desktopManager" "xfce" "thunarPlugins" ]
      [ "programs" "thunar" "plugins" ]
    )
  ];

  options = {
    environment.xfce.excludePackages = mkOption {
      default = [ ];
      description = "Which packages XFCE should exclude from the default environment";
      example = literalExpression "[ pkgs.xfce4-volumed-pulse ]";
      type = types.listOf types.package;
    };

    services.xserver.desktopManager.xfce = {
      enable = mkOption {
        default = false;
        description = "Enable the Xfce desktop environment.";
        type = types.bool;
      };

      enableScreensaver = mkOption {
        default = true;
        description = "Enable the XFCE screensaver.";
        type = types.bool;
      };

      enableWaylandSession = mkEnableOption "the experimental Xfce Wayland session";

      enableXfwm = mkOption {
        default = true;
        description = "Enable the XFWM (default) window manager.";
        type = types.bool;
      };

      noDesktop = mkOption {
        default = false;
        description = "Don't install XFCE desktop components (xfdesktop and panel).";
        type = types.bool;
      };

      waylandSessionCompositor = mkOption {
        default = "";

        description = ''
          Command line to run a Wayland compositor, defaults to `labwc --startup`
          if not specified. Note that `xfce4-session` will be passed to it as an
          argument, see `startxfce4 --help` for details.

          Some compositors do not have an option equivalent to labwc's `--startup`
          and you might have to add xfce4-session somewhere in their configurations.
        '';

        example = "wayfire";
        type = lib.types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    environment.pathsToLink = [
      "/share/xfce4"
      "/lib/xfce4"
      "/share/gtksourceview-3.0"
      "/share/gtksourceview-4.0"
    ];

    environment.systemPackages = utils.removePackagesByName (
      with pkgs;
      [
        glib # for gsettings
        gtk3.out # gtk-update-icon-cache

        gnome-themes-extra
        adwaita-icon-theme
        hicolor-icon-theme
        tango-icon-theme
        xfce4-icon-theme

        desktop-file-utils
        shared-mime-info # for update-mime-database

        # For a polkit authentication agent
        polkit_gnome

        # Needed by Xfce's xinitrc script
        xdg-user-dirs # Update user dirs as described in https://freedesktop.org/wiki/Software/xdg-user-dirs/

        xfce4-exo
        garcon
        libxfce4ui

        mousepad
        parole
        ristretto
        xfce4-appfinder
        xfce4-notifyd
        xfce4-screenshooter
        xfce4-session
        xfce4-settings
        xfce4-taskmanager
        xfce4-terminal
      ]
      # TODO: NetworkManager doesn't belong here
      ++ lib.optional config.networking.networkmanager.enable networkmanagerapplet
      ++ lib.optional config.powerManagement.enable xfce4-power-manager
      ++ lib.optionals (config.services.pulseaudio.enable || config.services.pipewire.pulse.enable) [
        pavucontrol
        # volume up/down keys support:
        # xfce4-pulseaudio-plugin includes all the functionalities of xfce4-volumed-pulse
        # but can only be used with xfce4-panel, so for no-desktop usage we still include
        # xfce4-volumed-pulse
        (if cfg.noDesktop then xfce4-volumed-pulse else xfce4-pulseaudio-plugin)
      ]
      ++ lib.optionals cfg.enableXfwm [
        xfwm4
        xfwm4-themes
      ]
      ++ lib.optionals (!cfg.noDesktop) [
        xfce4-panel
        xfdesktop
      ]
      ++ lib.optional cfg.enableScreensaver xfce4-screensaver
    ) excludePackages;

    # Shell integration for VTE terminals
    programs.bash.vteIntegration = mkDefault true;
    # Enable default programs
    programs.dconf.enable = true;
    programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
    programs.gnupg.agent.pinentryPackage = mkDefault pkgs.pinentry-gtk2;

    programs.labwc.enable = mkDefault (
      cfg.enableWaylandSession
      && (cfg.waylandSessionCompositor == "" || lib.substring 0 5 cfg.waylandSessionCompositor == "labwc")
    );

    programs.thunar.enable = true;
    programs.xfconf.enable = true;
    programs.zsh.vteIntegration = mkDefault true;
    security.pam.services.xfce4-screensaver.unixAuth = cfg.enableScreensaver;

    security.polkit = {
      enable = true;
      enablePkexecWrapper = lib.mkDefault true;
    };

    services.accounts-daemon.enable = true;
    services.colord.enable = mkDefault true;

    # Copied from https://gitlab.xfce.org/xfce/xfce4-session/-/blob/xfce4-session-4.19.2/xfce-wayland.desktop.in
    # to maintain consistent l10n state with X11 session file and to support the waylandSessionCompositor option.
    services.displayManager.sessionPackages = optionals cfg.enableWaylandSession [
      (
        (pkgs.writeTextDir "share/wayland-sessions/xfce-wayland.desktop" ''
          [Desktop Entry]
          Version=1.0
          Name=Xfce Session (Wayland)
          Comment=Use this session to run Xfce as your desktop environment
          Exec=startxfce4 --wayland ${cfg.waylandSessionCompositor}
          Icon=
          Type=Application
          DesktopNames=XFCE
          Keywords=xfce;wayland;desktop;environment;session;
        '').overrideAttrs
        (_: {
          passthru.providedSessions = [ "xfce-wayland" ];
        })
      )
    ];

    services.gnome.glib-networking.enable = true;
    services.gnome.gnome-keyring.enable = mkDefault true;
    services.gvfs.enable = true;
    services.libinput.enable = mkDefault true; # used in xfce4-settings-manager
    services.system-config-printer.enable = (mkIf config.services.printing.enable (mkDefault true));
    services.tumbler.enable = true;
    # Enable helpful DBus services.
    services.udisks2.enable = true;
    services.upower.enable = config.powerManagement.enable;

    services.xserver.desktopManager.session = [
      {
        bgSupport = !cfg.noDesktop;
        desktopNames = [ "XFCE" ];
        name = "xfce";
        prettyName = "Xfce Session";

        start = ''
          ${pkgs.runtimeShell} ${pkgs.xfce4-session.xinitrc} &
          waitPID=$!
        '';
      }
    ];

    services.xserver.updateDbusEnvironment = true;

    # Systemd services
    systemd.packages = utils.removePackagesByName (with pkgs; [
      xfce4-notifyd
    ]) excludePackages;

    xdg.portal.configPackages = mkDefault [ pkgs.xfce4-session ];
    xdg.portal.enable = mkDefault true;

    xdg.portal.extraPortals = utils.removePackagesByName (
      with pkgs;
      [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-xapp
      ]
      ++ lib.optionals cfg.enableWaylandSession [
        xdg-desktop-portal-wlr
      ]
    ) excludePackages;
  };

  meta = {
    teams = [ teams.xfce ];
  };
}
