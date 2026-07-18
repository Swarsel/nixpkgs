{
  lib,
  config,
  gnome,
  pkgs,
}:

lib.makeScope pkgs.newScope (
  self: with self; {

    #### APPS
    appcenter = callPackage ./apps/appcenter { };
    #### SERVICES
    contractor = callPackage ./services/contractor { };
    elementary-bluetooth-daemon = callPackage ./services/elementary-bluetooth-daemon { };
    elementary-calculator = callPackage ./apps/elementary-calculator { };
    elementary-calendar = callPackage ./apps/elementary-calendar { };
    elementary-camera = callPackage ./apps/elementary-camera { };
    elementary-capnet-assist = callPackage ./services/elementary-capnet-assist { };
    elementary-code = callPackage ./apps/elementary-code { };
    #### DESKTOP
    elementary-default-settings = callPackage ./desktop/elementary-default-settings { };
    elementary-dock = callPackage ./apps/elementary-dock { };
    elementary-feedback = callPackage ./apps/elementary-feedback { };
    elementary-files = callPackage ./apps/elementary-files { };
    elementary-greeter = callPackage ./desktop/elementary-greeter { };
    elementary-gsettings-schemas = callPackage ./desktop/elementary-gsettings-schemas { };
    ### ARTWORK
    elementary-gtk-theme = callPackage ./artwork/elementary-gtk-theme { };
    elementary-icon-theme = callPackage ./artwork/elementary-icon-theme { };
    elementary-iconbrowser = callPackage ./apps/elementary-iconbrowser { };
    elementary-mail = callPackage ./apps/elementary-mail { };
    elementary-maps = callPackage ./apps/elementary-maps { };
    elementary-monitor = callPackage ./apps/elementary-monitor { };
    elementary-music = callPackage ./apps/elementary-music { };
    elementary-notifications = callPackage ./services/elementary-notifications { };
    elementary-onboarding = callPackage ./desktop/elementary-onboarding { };
    elementary-photos = callPackage ./apps/elementary-photos { };
    elementary-print-shim = callPackage ./desktop/elementary-print-shim { };
    elementary-redacted-script = callPackage ./artwork/elementary-redacted-script { };
    elementary-screenshot = callPackage ./apps/elementary-screenshot { };
    elementary-session-settings = callPackage ./desktop/elementary-session-settings { };
    elementary-settings-daemon = callPackage ./services/elementary-settings-daemon { };
    elementary-shortcut-overlay = callPackage ./desktop/elementary-shortcut-overlay { };
    elementary-sound-theme = callPackage ./artwork/elementary-sound-theme { };
    elementary-tasks = callPackage ./apps/elementary-tasks { };
    elementary-terminal = callPackage ./apps/elementary-terminal { };
    elementary-videos = callPackage ./apps/elementary-videos { };
    elementary-wallpapers = callPackage ./artwork/elementary-wallpapers { };
    epiphany = pkgs.epiphany.override { withPantheon = true; };
    file-roller-contract = callPackage ./desktop/file-roller-contract { };
    gala = callPackage ./desktop/gala { };
    # Using 48 to match Mutter used in Pantheon
    gnome-settings-daemon = pkgs.gnome-settings-daemon48;
    #### LIBRARIES
    granite = callPackage ./libraries/granite { };
    granite7 = callPackage ./libraries/granite/7 { };
    live-chart = callPackage ./libraries/live-chart { };
    mutter = pkgs.mutter48;
    pantheon-agent-geoclue2 = callPackage ./services/pantheon-agent-geoclue2 { };
    pantheon-agent-polkit = callPackage ./services/pantheon-agent-polkit { };
    pantheon-wayland = callPackage ./libraries/pantheon-wayland { };
    sideload = callPackage ./apps/sideload { };
    #### SWITCHBOARD
    switchboard = callPackage ./apps/switchboard { };
    switchboard-plug-about = callPackage ./apps/switchboard-plugs/about { };
    switchboard-plug-applications = callPackage ./apps/switchboard-plugs/applications { };
    switchboard-plug-bluetooth = callPackage ./apps/switchboard-plugs/bluetooth { };
    switchboard-plug-datetime = callPackage ./apps/switchboard-plugs/datetime { };
    switchboard-plug-display = callPackage ./apps/switchboard-plugs/display { };
    switchboard-plug-keyboard = callPackage ./apps/switchboard-plugs/keyboard { };
    switchboard-plug-mouse-touchpad = callPackage ./apps/switchboard-plugs/mouse-touchpad { };
    switchboard-plug-network = callPackage ./apps/switchboard-plugs/network { };
    switchboard-plug-notifications = callPackage ./apps/switchboard-plugs/notifications { };
    switchboard-plug-onlineaccounts = callPackage ./apps/switchboard-plugs/onlineaccounts { };
    switchboard-plug-pantheon-shell = callPackage ./apps/switchboard-plugs/pantheon-shell { };
    switchboard-plug-parental-controls = callPackage ./apps/switchboard-plugs/parental-controls { };
    switchboard-plug-power = callPackage ./apps/switchboard-plugs/power { };
    switchboard-plug-printers = callPackage ./apps/switchboard-plugs/printers { };
    switchboard-plug-security-privacy = callPackage ./apps/switchboard-plugs/security-privacy { };
    switchboard-plug-sharing = callPackage ./apps/switchboard-plugs/sharing { };
    switchboard-plug-sound = callPackage ./apps/switchboard-plugs/sound { };
    switchboard-plug-wacom = callPackage ./apps/switchboard-plugs/wacom { };

    switchboard-with-plugs = callPackage ./apps/switchboard/wrapper.nix {
      plugs = null;
    };

    switchboardPlugs = [
      switchboard-plug-about
      switchboard-plug-applications
      switchboard-plug-bluetooth
      switchboard-plug-datetime
      switchboard-plug-display
      switchboard-plug-keyboard
      switchboard-plug-mouse-touchpad
      switchboard-plug-network
      switchboard-plug-notifications
      switchboard-plug-onlineaccounts
      switchboard-plug-pantheon-shell
      switchboard-plug-parental-controls
      switchboard-plug-power
      switchboard-plug-printers
      switchboard-plug-security-privacy
      switchboard-plug-sharing
      switchboard-plug-sound
      switchboard-plug-wacom
    ];

    teams = [ lib.teams.pantheon ];
    touchegg = pkgs.touchegg.override { withPantheon = true; };
    wingpanel = callPackage ./desktop/wingpanel { };
    #### WINGPANEL INDICATORS
    wingpanel-applications-menu = callPackage ./desktop/wingpanel-indicators/applications-menu { };
    wingpanel-indicator-a11y = callPackage ./desktop/wingpanel-indicators/a11y { };
    wingpanel-indicator-bluetooth = callPackage ./desktop/wingpanel-indicators/bluetooth { };
    wingpanel-indicator-datetime = callPackage ./desktop/wingpanel-indicators/datetime { };
    wingpanel-indicator-keyboard = callPackage ./desktop/wingpanel-indicators/keyboard { };
    wingpanel-indicator-network = callPackage ./desktop/wingpanel-indicators/network { };
    wingpanel-indicator-nightlight = callPackage ./desktop/wingpanel-indicators/nightlight { };
    wingpanel-indicator-notifications = callPackage ./desktop/wingpanel-indicators/notifications { };
    wingpanel-indicator-power = callPackage ./desktop/wingpanel-indicators/power { };
    wingpanel-indicator-sound = callPackage ./desktop/wingpanel-indicators/sound { };
    wingpanel-quick-settings = callPackage ./desktop/wingpanel-indicators/quick-settings { };

    wingpanel-with-indicators = callPackage ./desktop/wingpanel/wrapper.nix {
      indicators = null;
    };

    wingpanelIndicators = [
      elementary-monitor
      wingpanel-applications-menu
      wingpanel-indicator-bluetooth
      wingpanel-indicator-datetime
      wingpanel-indicator-keyboard
      wingpanel-indicator-network
      wingpanel-indicator-nightlight
      wingpanel-indicator-notifications
      wingpanel-indicator-power
      wingpanel-indicator-sound
      wingpanel-quick-settings
    ];

    xdg-desktop-portal-pantheon = callPackage ./services/xdg-desktop-portal-pantheon { };
    ### THIRD-PARTY
    # As suggested in https://github.com/NixOS/nixpkgs/issues/115222#issuecomment-906868654
    # please avoid putting third-party packages in the `pantheon` scope.

  }
)
// lib.optionalAttrs config.allowAliases {

  cerbere = throw "Cerbere is now obsolete https://github.com/elementary/cerbere/releases/tag/2.5.1."; # added 2020-04-06
  elementary-screenshot-tool = throw "The ‘pantheon.elementary-screenshot-tool’ alias was removed on 2022-02-02, please use ‘pantheon.elementary-screenshot’ directly."; # added 2021-07-21
  evince = pkgs.evince; # added 2022-03-18
  extra-elementary-contracts = throw "extra-elementary-contracts has been removed as all contracts have been upstreamed."; # added 2021-12-01
  file-roller = pkgs.file-roller; # added 2022-03-12
  gnome-bluetooth-contract = throw "pantheon.gnome-bluetooth-contract has been removed, abandoned by upstream."; # added 2022-06-30
  notes-up = throw "The ‘pantheon.notes-up’ alias was removed on 2022-02-02, please use ‘pkgs.notes-up’ directly."; # added 2021-12-18
  switchboard-plug-a11y = throw "pantheon.switchboard-plug-a11y has been removed, abandoned by upstream."; # added 2024-08-23
  ### ALIASES
  # They need to be outside the scope or they will shadow the attributes from parent scope.
  vala = throw "The ‘pantheon.vala’ alias was removed on 2022-02-02, please use ‘pkgs.vala’ directly."; # added 2019-10-10
  wingpanel-indicator-session = throw "pantheon.wingpanel-indicator-session has been removed, abandoned by upstream."; # added 2024-08-23

}
