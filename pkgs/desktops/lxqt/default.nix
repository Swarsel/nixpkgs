{
  kdePackages,
  makeScope,
  pkgs,
}:

let
  packages =
    self: with self; {

      compton-conf = callPackage ./compton-conf {
        inherit (pkgs.libsForQt5) qtbase qttools qtx11extras;
        lxqt-build-tools = lxqt-build-tools_0_13;
      };

      corePackages = [
        ### BASE
        libqtxdg
        libsysstat
        liblxqt
        qtxdg-tools
        libdbusmenu-lxqt

        ### CORE 1
        libfm-qt
        lxqt-about
        lxqt-admin
        lxqt-config
        lxqt-globalkeys
        lxqt-menu-data
        lxqt-notificationd
        lxqt-openssh-askpass
        lxqt-policykit
        lxqt-powermanagement
        lxqt-qtplugin
        lxqt-session
        lxqt-sudo
        lxqt-themes
        lxqt-wayland-session
        pavucontrol-qt

        ### CORE 2
        lxqt-panel
        lxqt-runner
        pcmanfm-qt
      ];

      libdbusmenu-lxqt = callPackage ./libdbusmenu-lxqt { };
      ### CORE 1
      libfm-qt = callPackage ./libfm-qt { };

      libfm-qt_1_4 = callPackage ./libfm-qt {
        inherit (pkgs.libsForQt5) qttools qtx11extras;
        version = "1.4.0";
        lxqt-build-tools = lxqt-build-tools_0_13;
      };

      liblxqt = callPackage ./liblxqt { };
      # For compiling information, see:
      # - https://github.com/lxqt/lxqt/wiki/Building-from-source
      ### BASE
      libqtxdg = callPackage ./libqtxdg { };

      libqtxdg_3_12 = callPackage ./libqtxdg {
        inherit (pkgs.libsForQt5) qtbase qtsvg;
        version = "3.12.0";
        lxqt-build-tools = lxqt-build-tools_0_13;
      };

      libsysstat = callPackage ./libsysstat { };
      lximage-qt = callPackage ./lximage-qt { };
      lxqt-about = callPackage ./lxqt-about { };
      lxqt-admin = callPackage ./lxqt-admin { };
      lxqt-archiver = callPackage ./lxqt-archiver { };
      lxqt-build-tools = callPackage ./lxqt-build-tools { };

      ### COMPATIBILITY
      lxqt-build-tools_0_13 = callPackage ./lxqt-build-tools {
        inherit (pkgs.libsForQt5) qtbase;
        version = "0.13.0";
      };

      lxqt-config = callPackage ./lxqt-config { };
      lxqt-globalkeys = callPackage ./lxqt-globalkeys { };
      lxqt-menu-data = callPackage ./lxqt-menu-data { };
      lxqt-notificationd = callPackage ./lxqt-notificationd { };
      lxqt-openssh-askpass = callPackage ./lxqt-openssh-askpass { };
      ### CORE 2
      lxqt-panel = callPackage ./lxqt-panel { };
      lxqt-policykit = callPackage ./lxqt-policykit { };
      lxqt-powermanagement = callPackage ./lxqt-powermanagement { };
      lxqt-qtplugin = callPackage ./lxqt-qtplugin { };
      lxqt-runner = callPackage ./lxqt-runner { };
      lxqt-session = callPackage ./lxqt-session { };
      lxqt-sudo = callPackage ./lxqt-sudo { };
      lxqt-themes = callPackage ./lxqt-themes { };
      lxqt-wayland-session = callPackage ./lxqt-wayland-session { };
      obconf-qt = callPackage ./obconf-qt { };

      optionalPackages = [
        ### LXQt project
        qterminal
        obconf-qt
        lximage-qt
        lxqt-archiver

        ### QtDesktop project
        qps
        screengrab

        ### Default icon theme
        kdePackages.breeze-icons

        ### Screen saver
        pkgs.xscreensaver
      ];

      pavucontrol-qt = callPackage ./pavucontrol-qt { };
      pcmanfm-qt = callPackage ./pcmanfm-qt { };

      preRequisitePackages = [
        kdePackages.kwindowsystem # provides some QT plugins needed by lxqt-panel
        kdePackages.libkscreen # provides plugins for screen management software
        pkgs.libfm
        pkgs.libfm-extra
        pkgs.menu-cache
        pkgs.openbox # default window manager
        kdePackages.qtsvg # provides QT plugins for svg icons
      ];

      qlipper = callPackage ./qlipper { };
      qps = callPackage ./qps { };
      ### OPTIONAL
      qterminal = callPackage ./qterminal { };
      qtermwidget = callPackage ./qtermwidget { };

      qtermwidget_1_4 = callPackage ./qtermwidget {
        inherit (pkgs.libsForQt5) qtbase qttools;
        version = "1.4.0";
        lxqt-build-tools = lxqt-build-tools_0_13;
      };

      qtxdg-tools = callPackage ./qtxdg-tools { };
      screengrab = callPackage ./screengrab { };
      xdg-desktop-portal-lxqt = callPackage ./xdg-desktop-portal-lxqt { };

    };
in
makeScope kdePackages.newScope packages
