{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  xcfg = config.services.xserver;
  dmcfg = config.services.displayManager;
  cfg = config.services.displayManager.sddm;
  xEnv = config.systemd.services.display-manager.environment;

  sddm = cfg.package.override (old: {
    extraPackages =
      old.extraPackages or [ ]
      ++ lib.optionals cfg.wayland.enable [ pkgs.qt6.qtwayland ]
      ++ lib.optionals (cfg.wayland.compositor == "kwin") [ pkgs.kdePackages.layer-shell-qt ]
      ++ cfg.extraPackages;
  });

  iniFmt = pkgs.formats.ini { };

  inherit (lib)
    concatMapStrings
    concatStringsSep
    getExe
    attrNames
    getAttr
    optionalAttrs
    optionalString
    mkRemovedOptionModule
    mkRenamedOptionModule
    mkIf
    mkEnableOption
    mkOption
    mkPackageOption
    types
    ;

  xserverWrapper = pkgs.writeShellScript "xserver-wrapper" ''
    ${concatMapStrings (n: "export ${n}=\"${getAttr n xEnv}\"\n") (attrNames xEnv)}
    exec systemd-cat -t xserver-wrapper ${xcfg.displayManager.xserverBin} ${toString xcfg.displayManager.xserverArgs} "$@"
  '';

  Xsetup = pkgs.writeShellScript "Xsetup" ''
    ${cfg.setupScript}
    ${xcfg.displayManager.setupCommands}
  '';

  Xstop = pkgs.writeShellScript "Xstop" ''
    ${cfg.stopScript}
  '';

  defaultConfig = {
    General = {
      # Implementation is done via pkgs/applications/display-managers/sddm/sddm-default-session.patch
      DefaultSession = optionalString (
        config.services.displayManager.defaultSession != null
      ) "${config.services.displayManager.defaultSession}.desktop";

      DisplayServer = if cfg.wayland.enable then "wayland" else "x11";
      HaltCommand = "/run/current-system/systemd/bin/systemctl poweroff";
      Numlock = if cfg.autoNumlock then "on" else "none"; # on, off none
      RebootCommand = "/run/current-system/systemd/bin/systemctl reboot";
    }
    // optionalAttrs (cfg.wayland.enable && cfg.wayland.compositor == "kwin") {
      GreeterEnvironment = "QT_WAYLAND_SHELL_INTEGRATION=layer-shell";
      InputMethod = ""; # needed if we are using --inputmethod with kwin
    };

    Theme = {
      Current = cfg.theme;
      FacesDir = "/run/current-system/sw/share/sddm/faces";
      ThemeDir = "/run/current-system/sw/share/sddm/themes";
    }
    // optionalAttrs (cfg.theme == "breeze") {
      CursorSize = 24;
      CursorTheme = "breeze_cursors";
    };

    Users = {
      HideShells = "/run/current-system/sw/bin/nologin";
      HideUsers = concatStringsSep "," dmcfg.hiddenUsers;
      MaximumUid = config.ids.uids.nixbld;
    };

    Wayland = {
      CompositorCommand = lib.optionalString cfg.wayland.enable cfg.wayland.compositorCommand;
      EnableHiDPI = cfg.enableHidpi;
      SessionDir = "${dmcfg.sessionData.desktops}/share/wayland-sessions";
    };

  }
  // optionalAttrs xcfg.enable {
    X11 = {
      DisplayCommand = toString Xsetup;
      DisplayStopCommand = toString Xstop;
      EnableHiDPI = cfg.enableHidpi;
      ServerPath = toString xserverWrapper;
      SessionCommand = toString dmcfg.sessionData.wrapper;
      SessionDir = "${dmcfg.sessionData.desktops}/share/xsessions";
      XauthPath = "${pkgs.xauth}/bin/xauth";
      XephyrPath = "${pkgs.xorg-server.out}/bin/Xephyr";
    };
  }
  // optionalAttrs dmcfg.autoLogin.enable {
    Autologin = {
      Relogin = cfg.autoLogin.relogin;
      Session = autoLoginSessionName;
      User = dmcfg.autoLogin.user;
    };
  };

  cfgFile = iniFmt.generate "sddm.conf" (lib.recursiveUpdate defaultConfig cfg.settings);

  autoLoginSessionName = "${dmcfg.sessionData.autologinSession}.desktop";

  compositorCmds = {
    kwin = concatStringsSep " " [
      "${lib.getBin pkgs.kdePackages.kwin}/bin/kwin_wayland"
      "--no-global-shortcuts"
      "--no-kactivities"
      "--no-lockscreen"
      "--locale1"
    ];

    # This is basically the upstream default, but with Weston referenced by full path
    # and the configuration generated from NixOS options.
    weston =
      let
        westonIni = (pkgs.formats.ini { }).generate "weston.ini" {
          keyboard = {
            keymap_layout = xcfg.xkb.layout;
            keymap_model = xcfg.xkb.model;
            keymap_options = xcfg.xkb.options;
            keymap_variant = xcfg.xkb.variant;
          };

          libinput = {
            enable-tap = config.services.libinput.mouse.tapping;
            left-handed = config.services.libinput.mouse.leftHanded;
          };
        };
      in
      "${getExe pkgs.weston} --shell=kiosk -c ${westonIni}";
  };

in
{
  imports = [
    (mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "sddm" "autoLogin" "minimumUid" ]
      [ "services" "displayManager" "sddm" "autoLogin" "minimumUid" ]
    )
    (mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "sddm" "autoLogin" "relogin" ]
      [ "services" "displayManager" "sddm" "autoLogin" "relogin" ]
    )
    (mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "sddm" "autoNumlock" ]
      [ "services" "displayManager" "sddm" "autoNumlock" ]
    )
    (mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "sddm" "enable" ]
      [ "services" "displayManager" "sddm" "enable" ]
    )
    (mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "sddm" "enableHidpi" ]
      [ "services" "displayManager" "sddm" "enableHidpi" ]
    )
    (mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "sddm" "extraPackages" ]
      [ "services" "displayManager" "sddm" "extraPackages" ]
    )
    (mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "sddm" "package" ]
      [ "services" "displayManager" "sddm" "package" ]
    )
    (mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "sddm" "settings" ]
      [ "services" "displayManager" "sddm" "settings" ]
    )
    (mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "sddm" "setupScript" ]
      [ "services" "displayManager" "sddm" "setupScript" ]
    )
    (mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "sddm" "stopScript" ]
      [ "services" "displayManager" "sddm" "stopScript" ]
    )
    (mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "sddm" "theme" ]
      [ "services" "displayManager" "sddm" "theme" ]
    )
    (mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "sddm" "wayland" "enable" ]
      [ "services" "displayManager" "sddm" "wayland" "enable" ]
    )

    (mkRemovedOptionModule [
      "services"
      "displayManager"
      "sddm"
      "themes"
    ] "Set the option `services.displayManager.sddm.package' instead.")
    (mkRenamedOptionModule
      [ "services" "displayManager" "sddm" "autoLogin" "enable" ]
      [ "services" "displayManager" "autoLogin" "enable" ]
    )
    (mkRenamedOptionModule
      [ "services" "displayManager" "sddm" "autoLogin" "user" ]
      [ "services" "displayManager" "autoLogin" "user" ]
    )
    (mkRemovedOptionModule [
      "services"
      "displayManager"
      "sddm"
      "extraConfig"
    ] "Set the option `services.displayManager.sddm.settings' instead.")
  ];

  options = {

    services.displayManager.sddm = {
      enable = mkOption {
        default = false;

        description = ''
          Whether to enable sddm as the display manager.
        '';

        type = types.bool;
      };

      package = mkPackageOption pkgs [ "kdePackages" "sddm" ] { };

      # Configuration for automatic login specific to SDDM
      autoLogin = {
        minimumUid = mkOption {
          default = 1000;

          description = ''
            Minimum user ID for auto-login user.
          '';

          type = types.ints.u16;
        };

        relogin = mkOption {
          default = false;

          description = ''
            If true automatic login will kick in again on session exit (logout), otherwise it
            will only log in automatically when the display-manager is started.
          '';

          type = types.bool;
        };
      };

      autoNumlock = mkOption {
        default = false;

        description = ''
          Enable numlock at login.
        '';

        type = types.bool;
      };

      enableHidpi = mkOption {
        default = true;

        description = ''
          Whether to enable automatic HiDPI mode.
        '';

        type = types.bool;
      };

      extraPackages = mkOption {
        default = [ ];
        defaultText = "[]";

        description = ''
          Extra Qt plugins / QML libraries to add to the environment.
        '';

        type = types.listOf types.package;
      };

      settings = mkOption {
        default = { };

        description = ''
          Extra settings merged in and overwriting defaults in sddm.conf.
        '';

        example = {
          Autologin = {
            Session = "plasma.desktop";
            User = "john";
          };
        };

        type = iniFmt.type;
      };

      setupScript = mkOption {
        default = "";

        description = ''
          A script to execute when starting the display server. DEPRECATED, please
          use {option}`services.xserver.displayManager.setupCommands`.
        '';

        example = ''
          # workaround for using NVIDIA Optimus without Bumblebee
          xrandr --setprovideroutputsource modesetting NVIDIA-0
          xrandr --auto
        '';

        type = types.str;
      };

      stopScript = mkOption {
        default = "";

        description = ''
          A script to execute when stopping the display server.
        '';

        type = types.str;
      };

      theme = mkOption {
        default = "";

        description = ''
          Greeter theme to use.
        '';

        example = lib.literalExpression "\"\${pkgs.where-is-my-sddm-theme.override { variants = [ \"qt5\" ]; }}/share/sddm/themes/where_is_my_sddm_theme_qt5\"";
        type = types.str;
      };

      # Experimental Wayland support
      wayland = {
        enable = mkEnableOption "experimental Wayland support";

        compositor = mkOption {
          default = "weston";
          description = "The compositor to use: ${lib.concatStringsSep ", " (builtins.attrNames compositorCmds)}";
          type = types.enum (builtins.attrNames compositorCmds);
        };

        compositorCommand = mkOption {
          default = compositorCmds.${cfg.wayland.compositor};
          description = "Command used to start the selected compositor";
          internal = true;
          type = types.str;
        };
      };
    };
  };

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion = xcfg.enable || cfg.wayland.enable;

        message = ''
          SDDM requires either services.xserver.enable or services.displayManager.sddm.wayland.enable to be true
        '';
      }
      {
        assertion = config.services.displayManager.autoLogin.enable -> autoLoginSessionName != null;

        message = ''
          SDDM auto-login requires that services.displayManager.defaultSession is set.
        '';
      }
    ];

    environment = {
      etc."sddm.conf.d/00-nixos.conf".source = cfgFile;

      pathsToLink = [
        "/share/sddm"
      ];

      systemPackages = [ sddm ];
    };

    security.pam.services = {
      sddm = {
        rules = {
          account = utils.pam.autoOrderRules [
            {
              control = "include";
              modulePath = "login";
              name = "login";
            }
          ];

          auth = utils.pam.autoOrderRules [
            {
              control = "substack";
              modulePath = "login";
              name = "login";
            }
          ];

          password = utils.pam.autoOrderRules [
            {
              control = "substack";
              modulePath = "login";
              name = "login";
            }
          ];

          session = utils.pam.autoOrderRules [
            {
              control = "include";
              modulePath = "login";
              name = "login";
            }
          ];
        };

        useDefaultRules = false;
      };

      sddm-autologin = {
        rules = {
          account = utils.pam.autoOrderRules [
            {
              control = "include";
              modulePath = "sddm";
              name = "sddm";
            }
          ];

          auth = utils.pam.autoOrderRules [
            {
              control = "requisite";
              modulePath = "${config.security.pam.package}/lib/security/pam_nologin.so";
              name = "nologin";
            }
            {
              args = lib.mkBefore [
                "uid"
                ">="
                (toString cfg.autoLogin.minimumUid)
              ];

              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
              name = "sddm-autologin-user";
              settings.quiet = true;
            }
            {
              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_permit.so";
              name = "permit";
            }
          ];

          password = utils.pam.autoOrderRules [
            {
              control = "include";
              modulePath = "sddm";
              name = "sddm";
            }
          ];

          session = utils.pam.autoOrderRules [
            {
              control = "include";
              modulePath = "sddm";
              name = "sddm";
            }
          ];
        };

        useDefaultRules = false;
      };

      sddm-greeter = {
        rules = {
          account = utils.pam.autoOrderRules [
            {
              args = lib.mkAfter [
                "user"
                "="
                "sddm"
              ];

              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
              name = "sddm-user";
              settings.audit = true;
              settings.quiet_success = true;
            }
            {
              control = "sufficient";
              modulePath = "${config.security.pam.package}/lib/security/pam_unix.so";
              name = "unix";
            }
          ];

          auth = utils.pam.autoOrderRules [
            {
              args = lib.mkAfter [
                "user"
                "="
                "sddm"
              ];

              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
              name = "sddm-user";
              settings.audit = true;
              settings.quiet_success = true;
            }
            {
              control = "optional";
              modulePath = "${config.security.pam.package}/lib/security/pam_permit.so";
              name = "permit";
            }
          ];

          password = utils.pam.autoOrderRules [
            {
              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_deny.so";
              name = "deny";
            }
          ];

          session = utils.pam.autoOrderRules [
            {
              args = lib.mkAfter [
                "user"
                "="
                "sddm"
              ];

              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
              name = "sddm-user";
              settings.audit = true;
              settings.quiet_success = true;
            }
            {
              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_env.so";
              name = "env";
              settings.conffile = "/etc/pam/environment";
              settings.readenv = 0;
            }
            {
              control = "optional";
              modulePath = "${config.systemd.package}/lib/security/pam_systemd.so";
              name = "systemd";
            }
            {
              control = "optional";
              modulePath = "${config.security.pam.package}/lib/security/pam_keyinit.so";
              name = "keyinit";
              settings.force = true;
              settings.revoke = true;
            }
            {
              control = "optional";
              modulePath = "${config.security.pam.package}/lib/security/pam_permit.so";
              name = "permit";
            }
          ];
        };

        useDefaultRules = false;
      };
    };

    services = {
      dbus.packages = [ sddm ];

      xserver = {
        # To enable user switching, allow sddm to allocate displays dynamically.
        display = null;
      };
    };

    services.displayManager = {
      enable = true;

      generic = {
        enable = true;
        execCmd = "exec /run/current-system/sw/bin/sddm";
      };
    };

    systemd = {
      # We're not using the upstream unit, so copy these: https://github.com/sddm/sddm/blob/develop/services/sddm.service.in
      services.display-manager = {
        after = [
          "systemd-user-sessions.service"
          "plymouth-quit.service"
          "systemd-logind.service"
        ];

        # sddm stores state in this directory, which should be mounted.
        unitConfig.RequiresMountsFor = [
          config.users.users.sddm.home
        ];
      };

      tmpfiles.packages = [ sddm ];
    };

    users.groups.sddm.gid = config.ids.gids.sddm;

    users.users.sddm = {
      createHome = true;
      group = "sddm";
      home = "/var/lib/sddm";
      uid = config.ids.uids.sddm;
    };
  };
}
