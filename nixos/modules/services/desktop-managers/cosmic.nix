# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Lily Foster <lily@lily.flowers>
# Portions of this code are adapted from nixos-cosmic
# https://github.com/lilyinstarlight/nixos-cosmic

{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.desktopManager.cosmic;
  notExcluded = pkg: utils.disablePackageByName pkg config.environment.cosmic.excludePackages;
  excludedCorePkgs = lib.lists.intersectLists corePkgs config.environment.cosmic.excludePackages;
  # **ONLY ADD PACKAGES WITHOUT WHICH COSMIC CRASHES, NOTHING ELSE**
  corePkgs =
    with pkgs;
    [
      cosmic-applets
      cosmic-app-library
      cosmic-bg
      cosmic-comp
      cosmic-files
      config.services.displayManager.cosmic-greeter.package
      cosmic-idle
      cosmic-initial-setup
      cosmic-launcher
      cosmic-notifications
      cosmic-osd
      cosmic-panel
      cosmic-session
      cosmic-settings
      cosmic-settings-daemon
      cosmic-workspaces-epoch
    ]
    ++ lib.optionals cfg.xwayland.enable [
      # Why would you want to enable XWayland but exclude the package
      # providing XWayland support? Doesn't make sense. Add `xwayland` to the
      # `corePkgs` list.
      xwayland
    ];
in
{
  options = {
    environment.cosmic.excludePackages = lib.mkOption {
      default = [ ];
      description = "List of packages to exclude from the COSMIC environment.";
      example = lib.literalExpression "[ pkgs.cosmic-player ]";
      type = lib.types.listOf lib.types.package;
    };

    services.desktopManager.cosmic = {
      enable = lib.mkEnableOption "COSMIC desktop environment";

      showExcludedPkgsWarning = lib.mkEnableOption "the warning for excluding core packages" // {
        default = true;
      };

      xwayland.enable = lib.mkEnableOption "Xwayland support for the COSMIC compositor" // {
        default = true;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Environment packages
    environment.pathsToLink = [
      "/share/backgrounds"
      "/share/cosmic"
      "/share/cosmic-layouts"
      "/share/cosmic-themes"
    ];

    # Required options for the COSMIC DE
    environment.sessionVariables.X11_BASE_RULES_XML = "${config.services.xserver.xkb.dir}/rules/base.xml";
    environment.sessionVariables.X11_EXTRA_RULES_XML = "${config.services.xserver.xkb.dir}/rules/base.extras.xml";

    environment.systemPackages = utils.removePackagesByName (
      corePkgs
      ++ (
        with pkgs;
        [
          adwaita-icon-theme
          alsa-utils
          cosmic-edit
          cosmic-icons
          cosmic-monitor
          cosmic-player
          cosmic-randr
          cosmic-reader
          cosmic-screenshot
          cosmic-term
          cosmic-wallpapers
          glib
          hicolor-icon-theme
          networkmanagerapplet
          playerctl
          pop-icon-theme
          pop-launcher
          pulseaudio
          xdg-user-dirs
        ]
        ++ lib.optionals config.services.flatpak.enable [
          # User may have Flatpaks enabled but might not want the `cosmic-store` package.
          cosmic-store
        ]
      )
    ) config.environment.cosmic.excludePackages;

    fonts.packages = with pkgs; [
      fira
      noto-fonts
      open-sans
    ];

    # Good to have defaults
    hardware.bluetooth.enable = lib.mkDefault true;
    networking.networkmanager.enable = lib.mkDefault true;
    programs.dconf.enable = true;
    programs.dconf.packages = [ pkgs.cosmic-session ];
    # Required for screen locker
    security.pam.services.cosmic-greeter = { };

    security.polkit = {
      enable = true;
      enablePkexecWrapper = lib.mkDefault true;
    };

    security.rtkit.enable = true;
    services.accounts-daemon.enable = true;
    services.acpid.enable = lib.mkDefault true;
    services.avahi.enable = lib.mkDefault true;
    services.displayManager.sessionPackages = [ pkgs.cosmic-session ];
    # geoclue2 stuff
    services.geoclue2.enable = true;
    # We _do_ use the demo agent in the `cosmic-settings-daemon` package,
    # but this option also creates a systemd service that conflicts with the
    # `cosmic-settings-daemon` package's geoclue2 agent. Therefore, disable it.
    services.geoclue2.enableDemoAgent = false;
    # As mentioned above, we do use the demo agent. And it needs to be
    # whitelisted, otherwise it doesn't run.
    services.geoclue2.whitelistedAgents = [ "geoclue-demo-agent" ]; # whitelist our own geoclue2 agent o
    services.gnome.gnome-keyring.enable = lib.mkDefault true;
    # Distro-wide defaults for graphical sessions
    services.graphical-desktop.enable = true;
    services.gvfs.enable = lib.mkDefault true;
    services.libinput.enable = true;
    services.orca.enable = lib.mkDefault (notExcluded pkgs.orca);

    services.power-profiles-daemon.enable = lib.mkDefault (
      !config.hardware.system76.power-daemon.enable
    );

    services.upower.enable = true;
    systemd.packages = [ pkgs.cosmic-session ];

    warnings = lib.optionals (cfg.showExcludedPkgsWarning && excludedCorePkgs != [ ]) [
      ''
        The `environment.cosmic.excludePackages` option was used to exclude some
        packages from the environment which also includes some packages that the
        maintainers of the COSMIC DE deem necessary for the COSMIC DE to start
        and initialize. Excluding said packages creates a high probability that
        the COSMIC DE will fail to initialize properly, or completely. This is an
        unsupported use case. If this was not intentional, please assign an empty
        list to the `environment.cosmic.excludePackages` option. If you want to
        exclude non-essential packages, please look at the NixOS module for the
        COSMIC DE and look for the essential packages in the `corePkgs` list.

        You can stop this warning from appearing by setting the option
        `services.desktopManager.cosmic.showExcludedPkgsWarning` to `false`.
      ''
    ];

    xdg = {
      icons.fallbackCursorThemes = lib.mkDefault [ "Cosmic" ];

      portal = {
        enable = true;
        configPackages = lib.mkDefault [ pkgs.xdg-desktop-portal-cosmic ];

        extraPortals = with pkgs; [
          xdg-desktop-portal-cosmic
          xdg-desktop-portal-gtk
        ];
      };

      # Required for cosmic-osd
      sounds.enable = true;
    };
  };

  meta.teams = [ lib.teams.cosmic ];
}
