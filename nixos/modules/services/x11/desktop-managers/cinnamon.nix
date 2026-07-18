{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

with lib;

let

  cfg = config.services.xserver.desktopManager.cinnamon;
  serviceCfg = config.services.cinnamon;

  nixos-gsettings-overrides = pkgs.cinnamon-gsettings-overrides.override {
    extraGSettingsOverridePackages = cfg.extraGSettingsOverridePackages;
    extraGSettingsOverrides = cfg.extraGSettingsOverrides;
  };

  notExcluded = pkg: utils.disablePackageByName pkg config.environment.cinnamon.excludePackages;
in

{
  options = {
    environment.cinnamon.excludePackages = mkOption {
      default = [ ];
      description = "Which packages cinnamon should exclude from the default environment";
      example = literalExpression "[ pkgs.blueman ]";
      type = types.listOf types.package;
    };

    services.cinnamon = {
      apps.enable = mkEnableOption "Cinnamon default applications";
    };

    services.xserver.desktopManager.cinnamon = {
      enable = mkEnableOption "the cinnamon desktop manager";

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

  config = mkMerge [
    (mkIf cfg.enable {
      # Have to take care of GDM + Cinnamon on Wayland users
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
        # FIXME: modules should link subdirs of `/share` rather than relying on this
        "/share" # TODO: https://github.com/NixOS/nixpkgs/issues/47173
      ];

      # Override GSettings schemas
      environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR = "${nixos-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas";

      environment.systemPackages =
        with pkgs;
        (
          [
            # Teach nemo-desktop how to launch file browser.
            # https://github.com/linuxmint/nemo/blob/6.4.0/src/nemo-desktop-application.c#L398
            (writeTextFile {
              destination = "/share/applications/x-cinnamon-mimeapps.list";
              name = "x-cinnamon-mimeapps";

              text = ''
                [Default Applications]
                inode/directory=nemo.desktop
              '';
            })

            desktop-file-utils

            # common-files
            cinnamon
            cinnamon-session
            cinnamon-desktop
            cinnamon-menus
            cinnamon-translations

            # utils needed by some scripts
            inxi
            killall

            # session requirements
            cinnamon-screensaver
            # cinnamon-killer-daemon: provided by cinnamon
            networkmanagerapplet # session requirement - also nm-applet not needed

            # packages
            nemo-with-extensions
            gnome-online-accounts-gtk
            cinnamon-control-center
            cinnamon-settings-daemon
            libgnomekbd

            # theme
            adwaita-icon-theme
            gnome-themes-extra
            gtk3.out

            # other
            glib # for gsettings
            xdg-user-dirs
          ]
          ++ utils.removePackagesByName [
            # accessibility
            onboard

            # theme
            sound-theme-freedesktop
            nixos-artwork.wallpapers.simple-dark-gray
            mint-artwork
            mint-cursor-themes
            mint-l-icons
            mint-l-theme
            mint-themes
            mint-x-icons
            mint-y-icons
            xapp # provides some xapp-* icons
            xapp-symbolic-icons
            xdg-user-dirs-gtk
          ] config.environment.cinnamon.excludePackages
        );

      # Default Fonts
      fonts.packages = with pkgs; [
        dejavu_fonts # Default monospace font in LMDE 6+
        ubuntu-classic # required for default theme
      ];

      hardware.bluetooth.enable = mkDefault true;
      networking.networkmanager.enable = mkDefault true;
      # Shell integration for VTE terminals
      programs.bash.vteIntegration = mkDefault true;
      # Enable dconf
      programs.dconf.enable = true;
      # For printers@cinnamon.org applet
      programs.system-config-printer.enable = (mkIf config.services.printing.enable (mkDefault true));
      programs.zsh.vteIntegration = mkDefault true;

      # Fix lockscreen
      security.pam.services = {
        cinnamon-screensaver = { };
      };

      security.polkit = {
        enable = true;
        enablePkexecWrapper = lib.mkDefault true;
      };

      services.accounts-daemon.enable = true;
      # Default services
      services.blueman.enable = mkDefault (notExcluded pkgs.blueman);
      services.cinnamon.apps.enable = mkDefault true;
      # Enable colord server
      services.colord.enable = true;

      services.dbus.packages = with pkgs; [
        cinnamon
        cinnamon-screensaver
        nemo-with-extensions
        xapp
      ];

      services.displayManager.sessionPackages = [ pkgs.cinnamon ];
      # Enable org.a11y.Bus
      services.gnome.at-spi2-core.enable = true;
      services.gnome.evolution-data-server.enable = true;
      services.gnome.gcr-ssh-agent.enable = mkDefault true;
      services.gnome.glib-networking.enable = true;
      services.gnome.gnome-keyring.enable = true;
      services.gnome.gnome-online-accounts.enable = mkDefault true;
      services.gvfs.enable = true;
      services.hardware.bolt.enable = mkDefault (notExcluded pkgs.bolt);
      services.libinput.enable = mkDefault true;
      services.orca.enable = mkDefault (notExcluded pkgs.orca);
      services.power-profiles-daemon.enable = mkDefault true;
      services.switcherooControl.enable = mkDefault true; # xapp-gpu-offload-helper
      services.touchegg.enable = mkDefault true;
      services.udisks2.enable = true;
      services.upower.enable = mkDefault config.powerManagement.enable;

      services.xserver.displayManager.lightdm.greeters.slick = {
        enable = mkDefault true;

        cursorTheme = mkIf (notExcluded pkgs.mint-cursor-themes) {
          package = mkDefault pkgs.mint-cursor-themes;
          name = mkDefault "Bibata-Modern-Classic";
        };

        iconTheme = mkIf (notExcluded pkgs.mint-y-icons) {
          package = mkDefault pkgs.mint-y-icons;
          name = mkDefault "Mint-Y-Sand";
        };

        # Taken from mint-artwork.gschema.override
        theme = mkIf (notExcluded pkgs.mint-themes) {
          package = mkDefault pkgs.mint-themes;
          name = mkDefault "Mint-Y-Aqua";
        };
      };

      services.xserver.updateDbusEnvironment = true;

      systemd.packages =
        with pkgs;
        [
          cinnamon-session
        ]
        ++ utils.removePackagesByName [
          xdg-user-dirs # Update user dirs as described in https://freedesktop.org/wiki/Software/xdg-user-dirs/
          xdg-user-dirs-gtk
        ] config.environment.cinnamon.excludePackages;

      xdg.icons.enable = true;
      xdg.mime.enable = true;
      xdg.portal.configPackages = mkDefault [ pkgs.cinnamon ];
      xdg.portal.enable = true;

      xdg.portal.extraPortals = [
        pkgs.xdg-desktop-portal-xapp
        pkgs.xdg-desktop-portal-gtk
      ];
    })

    (mkIf serviceCfg.apps.enable {
      environment.systemPackages =
        with pkgs;
        utils.removePackagesByName [
          # cinnamon team apps
          bulky
          warpinator

          # cinnamon xapp
          xviewer
          xreader
          xed-editor
          pix

          # external apps shipped with linux-mint
          celluloid
          gnome-calculator
          gnome-calendar
          gnome-screenshot
          file-roller
          gucharmap
        ] config.environment.cinnamon.excludePackages;

      programs.gnome-disks.enable = mkDefault (notExcluded pkgs.gnome-disk-utility);
      programs.gnome-terminal.enable = mkDefault (notExcluded pkgs.gnome-terminal);
    })
  ];
}
