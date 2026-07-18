{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  inherit (lib)
    concatMapStrings
    literalExpression
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.services.desktopManager.budgie;

  nixos-background-light = pkgs.nixos-artwork.wallpapers.nineish;
  nixos-background-dark = pkgs.nixos-artwork.wallpapers.nineish-dark-gray;

  nixos-gsettings-overrides = pkgs.budgie-gsettings-overrides.override {
    inherit (cfg) extraGSettingsOverrides extraGSettingsOverridePackages;
    inherit nixos-background-dark nixos-background-light;
  };

  nixos-background-info = pkgs.writeTextFile {
    destination = "/share/gnome-background-properties/nixos.xml";
    name = "nixos-background-info";

    text = ''
      <?xml version="1.0"?>
      <!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
      <wallpapers>
        <wallpaper deleted="false">
          <name>Nineish</name>
          <filename>${nixos-background-light.gnomeFilePath}</filename>
          <options>zoom</options>
          <shade_type>solid</shade_type>
          <pcolor>#d1dcf8</pcolor>
          <scolor>#e3ebfe</scolor>
        </wallpaper>
        <wallpaper deleted="false">
          <name>Nineish Dark Gray</name>
          <filename>${nixos-background-dark.gnomeFilePath}</filename>
          <options>zoom</options>
          <shade_type>solid</shade_type>
          <pcolor>#151515</pcolor>
          <scolor>#262626</scolor>
        </wallpaper>
      </wallpapers>
    '';
  };

  budgie-control-center' = pkgs.budgie-control-center.override {
    enableSshSocket = config.services.openssh.startWhenNeeded;
  };

  notExcluded = pkg: utils.disablePackageByName pkg config.environment.budgie.excludePackages;
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "xserver" "desktopManager" "budgie" ]
      [ "services" "desktopManager" "budgie" ]
    )
  ];

  options = {
    environment.budgie.excludePackages = mkOption {
      default = [ ];
      description = "Which packages Budgie should exclude from the default environment.";
      example = literalExpression "[ pkgs.mate-terminal ]";
      type = types.listOf types.package;
    };

    services.desktopManager.budgie = {
      enable = mkEnableOption "the Budgie desktop";

      extraGSettingsOverridePackages = mkOption {
        default = [ ];
        description = "List of packages for which GSettings are overridden.";
        type = types.listOf types.path;
      };

      extraGSettingsOverrides = mkOption {
        default = "";
        description = "Additional GSettings overrides.";
        type = types.lines;
      };

      extraPlugins = mkOption {
        default = [ ];
        description = "Extra plugins for the Budgie desktop";
        example = literalExpression "[ pkgs.budgie-analogue-clock-applet ]";
        type = types.listOf types.package;
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
  };

  config = mkIf cfg.enable {
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
    ''
    + lib.optionalString config.services.gnome.gcr-ssh-agent.enable ''
      # Hack: https://bugzilla.redhat.com/show_bug.cgi?id=2250704 still
      # applies to sessions not managed by systemd.
      if [ -z "$SSH_AUTH_SOCK" ] && [ -n "$XDG_RUNTIME_DIR" ]; then
        export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"
      fi
    '';

    environment.pathsToLink = [
      "/share" # TODO: https://github.com/NixOS/nixpkgs/issues/47173
    ];

    # GSettings overrides.
    environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR = "${nixos-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas";

    environment.systemPackages =
      with pkgs;
      [
        # Budgie Desktop.
        budgie-backgrounds
        budgie-control-center'
        budgie-desktop-services
        (budgie-desktop-with-plugins.override { plugins = cfg.extraPlugins; })
        budgie-desktop-view
        budgie-session

        # Required by Budgie Menu.
        gnome-menus

        # Required by Budgie Control Center.
        zenity

        # Provides `gsettings`.
        glib

        # Update user directories.
        xdg-user-dirs
      ]
      ++ lib.optional config.networking.networkmanager.enable pkgs.networkmanagerapplet
      ++ (utils.removePackagesByName [
        bluejay
        nemo
        eom
        pluma
        atril
        engrampa
        mate-calc
        mate-system-monitor
        vlc

        # Supplemental tooling.
        # See budgie-desktop's with-runtime-dependencies meson option.
        gammastep
        grim
        killall
        mesa-demos # eglinfo
        slurp
        swaybg
        swayidle
        wdisplays
        wlopm

        # Desktop themes.
        qogir-theme
        qogir-icon-theme
        nixos-background-info

        # Default settings.
        nixos-gsettings-overrides
      ] config.environment.budgie.excludePackages)
      ++ cfg.sessionPath;

    fonts.fontconfig.defaultFonts = {
      monospace = mkDefault [ "Hack" ];
      sansSerif = mkDefault [ "Noto Sans" ];
    };

    # Fonts.
    fonts.packages = [
      pkgs.noto-fonts
      pkgs.hack-font
    ];

    hardware.bluetooth.enable = mkDefault true; # for Budgie's Status Indicator and Bluejay.
    # Required by Budgie Panel plugins and/or Budgie Control Center panels.
    networking.networkmanager.enable = mkDefault true; # for BCC's Network panel.
    # Shell integration for MATE Terminal.
    programs.bash.vteIntegration = true;
    programs.dconf.enable = true;
    # Both budgie-desktop-view and nemo defaults to this emulator.
    programs.gnome-terminal.enable = mkDefault (notExcluded pkgs.gnome-terminal);
    programs.gtklock.enable = mkDefault true;
    # https://docs.buddiesofbudgie.org/10.10/developer/workflow/building-budgie-desktop/#compositor-recommendations
    programs.labwc.enable = mkDefault true;
    programs.nm-applet.enable = config.networking.networkmanager.enable; # Budgie has no Network applet.
    programs.nm-applet.indicator = true; # Budgie uses AppIndicators.
    programs.zsh.vteIntegration = true;
    # Required by Budgie's Polkit Dialog.
    security.polkit.enable = mkDefault true;
    # Required by Budige's Control Center and Desktop
    security.polkit.enablePkexecWrapper = mkDefault true;
    services.accounts-daemon.enable = mkDefault true; # for BCC's Users panel.
    services.colord.enable = mkDefault true; # for BCC's Color panel.

    # Register packages for DBus.
    services.dbus.packages = [
      budgie-control-center'
      pkgs.budgie-desktop-services
    ];

    services.desktopManager.budgie.sessionPath = [ pkgs.budgie-desktop-view ];

    services.displayManager.sessionPackages = with pkgs; [
      budgie-desktop
    ];

    # For BCC's Sharing panel.
    services.dleyna.enable = mkDefault true;
    services.geoclue2.enable = mkDefault true; # for BCC's Privacy > Location Services panel.
    services.gnome.at-spi2-core.enable = mkDefault true; # for BCC's A11y panel.
    # Other default services.
    services.gnome.evolution-data-server.enable = mkDefault true;
    services.gnome.gcr-ssh-agent.enable = mkDefault true;
    services.gnome.glib-networking.enable = mkDefault true;
    services.gnome.gnome-keyring.enable = mkDefault true;
    # For BCC's Online Accounts panel.
    services.gnome.gnome-online-accounts.enable = mkDefault true;
    services.gnome.gnome-settings-daemon.enable = mkDefault true;
    services.gnome.gnome-user-share.enable = mkDefault true;
    services.gnome.rygel.enable = mkDefault true;
    services.gvfs.enable = mkDefault true;
    services.libinput.enable = mkDefault true; # for BCC's Mouse panel.
    # For BCC's Printers panel.
    services.printing.enable = mkDefault true;
    services.system-config-printer.enable = config.services.printing.enable;
    services.udisks2.enable = mkDefault true; # for BCC's Details panel.
    services.upower.enable = config.powerManagement.enable; # for Budgie's Status Indicator and BCC's Power panel.

    services.xserver.displayManager.lightdm.greeters.slick = {
      enable = mkDefault true;

      cursorTheme = mkDefault {
        package = pkgs.qogir-icon-theme;
        name = "Qogir";
      };

      iconTheme = mkDefault {
        package = pkgs.qogir-icon-theme;
        name = "Qogir";
      };

      theme = mkDefault {
        package = pkgs.qogir-theme;
        name = "Qogir";
      };
    };

    # Required by Budgie Desktop.
    services.xserver.updateDbusEnvironment = true;
    xdg.portal.configPackages = mkDefault [ pkgs.budgie-desktop ];
    xdg.portal.enable = mkDefault true; # for BCC's Applications panel.

    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gtk # provides a XDG Portals implementation.
      xdg-desktop-portal-wlr # for screenshot and screencast.
    ];
  };

  meta.teams = [ lib.teams.budgie ];
}
