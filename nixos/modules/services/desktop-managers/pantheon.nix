{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

with lib;

let

  cfg = config.services.desktopManager.pantheon;
  serviceCfg = config.services.pantheon;

  nixos-gsettings-desktop-schemas = pkgs.pantheon.elementary-gsettings-schemas.override {
    extraGSettingsOverridePackages = cfg.extraGSettingsOverridePackages;
    extraGSettingsOverrides = cfg.extraGSettingsOverrides;
  };

  notExcluded = pkg: utils.disablePackageByName pkg config.environment.pantheon.excludePackages;
in

{

  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "xserver" "desktopManager" "pantheon" ]
      [ "services" "desktopManager" "pantheon" ]
    )
  ];

  options = {

    environment.pantheon.excludePackages = mkOption {
      default = [ ];
      description = "Which packages pantheon should exclude from the default environment";
      example = literalExpression "[ pkgs.pantheon.elementary-camera ]";
      type = types.listOf types.package;
    };

    services.desktopManager.pantheon = {
      enable = mkOption {
        default = false;
        description = "Enable the pantheon desktop manager";
        type = types.bool;
      };

      debug = mkEnableOption "gnome-session debug messages";

      extraGSettingsOverridePackages = mkOption {
        default = [ ];
        description = "List of packages for which gsettings are overridden.";
        type = types.listOf types.path;
      };

      extraGSettingsOverrides = mkOption {
        default = "";
        description = "Additional gsettings overrides.";
        type = types.lines;
      };

      extraSwitchboardPlugs = mkOption {
        default = null;
        description = "Plugs to add to Switchboard.";
        type = with types; nullOr (listOf package);
      };

      extraWingpanelIndicators = mkOption {
        default = null;
        description = "Indicators to add to Wingpanel.";
        type = with types; nullOr (listOf package);
      };

      sessionPath = mkOption {
        default = [ ];

        description = ''
          Additional list of packages to be added to the session search path.
          Useful for GSettings-conditional autostart.

          Note that this should be a last resort; patching the package is preferred (see GPaste).
        '';

        example = literalExpression "[ pkgs.gpaste ]";
        type = types.listOf types.package;
      };

    };

    services.pantheon = {

      apps.enable = mkEnableOption "Pantheon default applications";

      contractor = {
        enable = mkEnableOption "contractor, a desktop-wide extension service used by Pantheon";
      };

      parental-controls.enable = mkEnableOption "Pantheon parental controls daemon";

    };

  };

  config = mkMerge [
    (mkIf cfg.enable {
      # Settings from elementary-default-settings
      # GTK4 will try both $XDG_CONFIG_DIRS/gtk-4.0 and ${gtk4}/etc/gtk-4.0, but not /etc/gtk-4.0.
      environment.etc."xdg/gtk-4.0/settings.ini".source =
        "${pkgs.pantheon.elementary-default-settings}/etc/gtk-4.0/settings.ini";

      environment.extraInit = ''
        ${concatMapStrings (p: ''
          if [ -d "${p}/share/gsettings-schemas/${p.name}" ]; then
            export XDG_DATA_DIRS=$XDG_DATA_DIRS''${XDG_DATA_DIRS:+:}${p}/share/gsettings-schemas/${p.name}
          fi

          if [ -d "${p}/lib/girepository-1.0" ]; then
            export GI_TYPELIB_PATH=$GI_TYPELIB_PATH''${GI_TYPELIB_PATH:+:}${p}/lib/girepository-1.0
            export LD_LIBRARY_PATH=$LD_LIBRARY_PATH''${LD_LIBRARY_PATH:+:}${p}/lib
          fi
        '') cfg.sessionPath}
      '';

      environment.pathsToLink = [
        # FIXME: modules should link subdirs of `/share` rather than relying on this
        "/share"
      ];

      environment.sessionVariables.GNOME_SESSION_DEBUG = mkIf cfg.debug "1";
      # Override GSettings schemas
      environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR = "${nixos-gsettings-desktop-schemas}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas";

      # Global environment
      environment.systemPackages =
        (with pkgs.pantheon; [
          elementary-session-settings
          gala
          gnome-settings-daemon
          (switchboard-with-plugs.override {
            plugs = cfg.extraSwitchboardPlugs;
          })
          (wingpanel-with-indicators.override {
            indicators = cfg.extraWingpanelIndicators;
          })
        ])
        ++ utils.removePackagesByName (
          (with pkgs; [
            desktop-file-utils
            glib # for gsettings program
            gnome-menus
            adwaita-icon-theme
            gtk3.out # for gtk-launch program
            sound-theme-freedesktop
            xdg-user-dirs # Update user dirs as described in https://freedesktop.org/wiki/Software/xdg-user-dirs/
          ])
          ++ (with pkgs.pantheon; [
            # Artwork
            elementary-gtk-theme
            elementary-icon-theme
            elementary-sound-theme
            elementary-wallpapers

            # Desktop
            elementary-default-settings
            elementary-dock
            elementary-shortcut-overlay

            # Services
            elementary-bluetooth-daemon
            elementary-capnet-assist
            elementary-notifications
            elementary-settings-daemon
            pantheon-agent-geoclue2
            pantheon-agent-polkit
          ])
        ) config.environment.pantheon.excludePackages;

      fonts.fontconfig.defaultFonts = {
        monospace = [ "Roboto Mono" ];
        sansSerif = [ "Inter" ];
      };

      # Default Fonts
      fonts.packages = with pkgs; [
        inter
        open-dyslexic
        open-sans
        roboto-mono
      ];

      # Default services
      hardware.bluetooth.enable = mkDefault true;
      networking.networkmanager.enable = mkDefault true;
      # Shell integration for VTE terminals
      programs.bash.vteIntegration = mkDefault true;
      programs.dconf.enable = true;

      programs.dconf.profiles.user.databases = [
        {
          settings."io/elementary/greeter" = {
            last-session-type = "pantheon-wayland";
          };
        }
      ];

      # Otherwise you can't store NetworkManager Secrets with
      # "Store the password only for this user"
      programs.nm-applet.enable = true;
      # Pantheon has its own network indicator
      programs.nm-applet.indicator = false;
      programs.zsh.vteIntegration = mkDefault true;
      security.polkit.enable = true;
      services.accounts-daemon.enable = true;
      services.colord.enable = mkDefault true;

      services.dbus.packages = with pkgs.pantheon; [
        switchboard-plug-power
        elementary-default-settings # accountsservice extensions
      ];

      services.desktopManager.pantheon.sessionPath = utils.removePackagesByName [
        pkgs.pantheon.pantheon-agent-geoclue2
      ] config.environment.pantheon.excludePackages;

      # Without this, elementary LightDM greeter will pre-select non-existent `default` session
      # https://github.com/elementary/greeter/issues/368
      services.displayManager.defaultSession = mkDefault "pantheon-wayland";
      services.displayManager.sessionPackages = [ pkgs.pantheon.elementary-session-settings ];
      services.fwupd.enable = mkDefault true;

      services.geoclue2.appConfig."io.elementary.desktop.agent-geoclue2" = {
        isAllowed = true;
        isSystem = true;
      };

      services.geoclue2.enable = mkDefault true;
      # pantheon has pantheon-agent-geoclue2
      services.geoclue2.enableDemoAgent = false;
      services.gnome.at-spi2-core.enable = true;
      services.gnome.evolution-data-server.enable = true;
      services.gnome.gcr-ssh-agent.enable = mkDefault true;
      services.gnome.glib-networking.enable = true;
      services.gnome.gnome-keyring.enable = true;
      services.gnome.rygel.enable = mkDefault true;
      services.gvfs.enable = true;
      services.libinput.enable = mkDefault true;
      services.orca.enable = mkDefault (notExcluded pkgs.orca);
      services.pantheon.apps.enable = mkDefault true;
      services.pantheon.contractor.enable = mkDefault true;
      services.pantheon.parental-controls.enable = mkDefault true;
      # TODO: Enable once #177946 is resolved
      # services.packagekit.enable = mkDefault true;
      services.power-profiles-daemon.enable = mkDefault true;
      services.switcherooControl.enable = mkDefault true;
      services.system-config-printer.enable = (mkIf config.services.printing.enable (mkDefault true));
      services.touchegg.enable = mkDefault true;
      services.touchegg.package = pkgs.pantheon.touchegg;
      services.tumbler.enable = mkDefault true;

      services.udev.packages = [
        pkgs.pantheon.gnome-settings-daemon
        # Force enable KMS modifiers for devices that require them.
        # https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1443
        pkgs.pantheon.mutter
      ];

      services.udisks2.enable = true;
      services.upower.enable = config.powerManagement.enable;
      services.xserver.displayManager.lightdm.greeters.pantheon.enable = mkDefault true;
      services.zeitgeist.enable = mkDefault true;

      systemd.packages = with pkgs; [
        gnome-session
        pantheon.gala
        pantheon.gnome-settings-daemon
        pantheon.elementary-session-settings
        pantheon.elementary-settings-daemon
      ];

      systemd.user.services."io.elementary.settings-daemon" = {
        # The daemon might launch external applications via g_app_info_launch.
        environment.PATH = lib.mkForce null;
        # https://github.com/NixOS/nixpkgs/issues/81138
        wantedBy = [ "gnome-session-initialized.target" ];
      };

      systemd.user.targets."gnome-session-x11-services".wants = [
        "org.gnome.SettingsDaemon.XSettings.service"
      ];

      systemd.user.targets."gnome-session-x11-services-ready".wants = [
        "org.gnome.SettingsDaemon.XSettings.service"
      ];

      # Ensure lightdm is used when Pantheon is enabled
      # Without it screen locking will be nonfunctional because of the use of lightlocker
      warnings = optional (config.services.xserver.displayManager.lightdm.enable != true) ''
        Using Pantheon without LightDM as a displayManager will break screenlocking from the UI.
      '';

      xdg.icons.enable = true;
      xdg.mime.enable = true;
      xdg.portal.configPackages = mkDefault [ pkgs.pantheon.elementary-default-settings ];
      xdg.portal.enable = true;

      xdg.portal.extraPortals = utils.removePackagesByName (
        [
          pkgs.xdg-desktop-portal-gtk
        ]
        ++ (with pkgs.pantheon; [
          elementary-files
          elementary-settings-daemon
          xdg-desktop-portal-pantheon
        ])
      ) config.environment.pantheon.excludePackages;
    })

    (mkIf serviceCfg.apps.enable {
      environment.systemPackages = utils.removePackagesByName (
        [
          pkgs.gnome-font-viewer
          pkgs.file-roller
        ]
        ++ (
          with pkgs.pantheon;
          [
            elementary-calculator
            elementary-calendar
            elementary-camera
            elementary-code
            elementary-files
            elementary-mail
            elementary-maps
            elementary-monitor
            elementary-music
            elementary-photos
            elementary-screenshot
            elementary-tasks
            elementary-terminal
            elementary-videos
            epiphany
          ]
          ++ lib.optionals config.services.flatpak.enable [
            # Only install appcenter if flatpak is enabled before
            # https://github.com/NixOS/nixpkgs/issues/15932 is resolved.
            appcenter
            sideload
          ]
        )
      ) config.environment.pantheon.excludePackages;

      # needed by screenshot
      fonts.packages = [
        pkgs.pantheon.elementary-redacted-script
      ];

      programs.evince.enable = mkDefault (notExcluded pkgs.evince);
    })

    (mkIf serviceCfg.contractor.enable {
      environment.pathsToLink = [
        "/share/contractor"
      ];

      environment.systemPackages = with pkgs.pantheon; [
        contractor
        file-roller-contract
      ];
    })

    (mkIf serviceCfg.parental-controls.enable {
      environment.systemPackages = [ pkgs.pantheon.switchboard-plug-parental-controls ];
      services.dbus.packages = [ pkgs.pantheon.switchboard-plug-parental-controls ];
      services.malcontent.enable = mkDefault true;
      systemd.packages = [ pkgs.pantheon.switchboard-plug-parental-controls ];
    })
  ];

  meta = {
    doc = ./pantheon.md;
    teams = [ teams.pantheon ];
  };
}
