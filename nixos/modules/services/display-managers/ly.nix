{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  dmcfg = config.services.displayManager;
  xcfg = config.services.xserver;
  xdmcfg = xcfg.displayManager;
  cfg = config.services.displayManager.ly;
  xEnv = config.systemd.services.display-manager.environment;

  ly = cfg.package.override { x11Support = cfg.x11Support; };

  iniFmt = pkgs.formats.iniWithGlobalSection { };

  inherit (lib)
    attrNames
    concatMapStrings
    getAttr
    mkIf
    mkOption
    mkEnableOption
    mkPackageOption
    optionalAttrs
    ;

  xserverWrapper = pkgs.writeShellScript "xserver-wrapper" ''
    ${concatMapStrings (n: ''
      export ${n}="${getAttr n xEnv}"
    '') (attrNames xEnv)}
    exec systemd-cat -t xserver-wrapper ${xdmcfg.xserverBin} ${toString xdmcfg.xserverArgs} "$@"
  '';

  defaultConfig = {
    brightness_down_cmd = "${lib.getExe pkgs.brightnessctl} -q -n s 10%-";
    brightness_up_cmd = "${lib.getExe pkgs.brightnessctl} -q -n s +10%";
    path = "/run/current-system/sw/bin";
    restart_cmd = "/run/current-system/systemd/bin/systemctl reboot";
    service_name = "ly";
    setup_cmd = dmcfg.sessionData.wrapper;
    shutdown_cmd = "/run/current-system/systemd/bin/systemctl poweroff";
    term_reset_cmd = "${pkgs.ncurses}/bin/tput reset";
    term_restore_cursor_cmd = "${pkgs.ncurses}/bin/tput cnorm";
    waylandsessions = "${dmcfg.sessionData.desktops}/share/wayland-sessions";
    x_cmd = lib.optionalString xcfg.enable xserverWrapper;
    xauth_cmd = lib.optionalString xcfg.enable "${pkgs.xauth}/bin/xauth";
    xsessions = "${dmcfg.sessionData.desktops}/share/xsessions";
  }
  // optionalAttrs dmcfg.autoLogin.enable {
    auto_login_service = "ly-autologin";
    auto_login_session = dmcfg.sessionData.autologinSession;
    auto_login_user = dmcfg.autoLogin.user;
  };

  finalConfig = defaultConfig // cfg.settings;

  cfgFile = iniFmt.generate "config.ini" { globalSection = finalConfig; };

in
{
  options = {
    services.displayManager.ly = {
      enable = mkEnableOption "ly as the display manager";
      package = mkPackageOption pkgs [ "ly" ] { };

      settings = mkOption {
        default = { };

        description = ''
          Extra settings merged in and overwriting defaults in config.ini.
        '';

        example = {
          load = false;
          save = false;
        };

        type = with lib.types; attrsOf iniFmt.lib.types.atom;
      };

      x11Support = mkOption {
        default = true;
        description = "Whether to enable support for X11";
        type = lib.types.bool;
      };
    };
  };

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion = dmcfg.autoLogin.enable -> dmcfg.sessionData.autologinSession != null;

        message = ''
          ly auto-login requires that services.displayManager.defaultSession is set.
        '';
      }
    ];

    environment = {
      etc."ly/config.ini".source = cfgFile;
      pathsToLink = [ "/share/ly" ];
      systemPackages = [ ly ];
    };

    security.pam.services = {
      ly = {
        enableGnomeKeyring = lib.mkDefault config.services.gnome.gnome-keyring.enable;
        startSession = true;
        unixAuth = true;
      };
    }
    // optionalAttrs dmcfg.autoLogin.enable {
      ly-autologin = {
        rules = {
          account = utils.pam.autoOrderRules [
            {
              control = "include";
              modulePath = "ly";
              name = "ly";
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
                "1000"
              ];

              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
              name = "ly-normal-user";
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
              modulePath = "ly";
              name = "ly";
            }
          ];

          session = utils.pam.autoOrderRules [
            {
              control = "include";
              modulePath = "ly";
              name = "ly";
            }
          ];
        };

        useDefaultRules = false;
      };
    };

    services = {
      dbus.packages = [ ly ];

      displayManager = {
        enable = true;

        generic = {
          enable = true;
          execCmd = "exec /run/current-system/sw/bin/ly";
        };

        # Set this here instead of 'defaultConfig' so users get eval
        # errors when they change it.
        ly.settings.tty = 1;
      };

      xserver = {
        # To enable user switching, allow ly to allocate displays dynamically.
        display = null;
      };
    };

    systemd = {
      # We're not using the upstream unit, so copy these:
      # https://github.com/fairyglade/ly/blob/master/res/ly.service
      services.display-manager = {
        after = [
          "systemd-user-sessions.service"
          "plymouth-quit-wait.service"
        ];

        serviceConfig = {
          StandardInput = "tty";
          TTYPath = "/dev/tty${toString finalConfig.tty}";
          TTYReset = "yes";
          TTYVHangup = "yes";
          Type = "idle";
        };
      };
    };
  };

  meta.maintainers = with lib.maintainers; [
    vonfry
    zacharyarnaise
  ];
}
