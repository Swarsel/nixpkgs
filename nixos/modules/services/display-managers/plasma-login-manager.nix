{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    mkPackageOption
    optionalAttrs
    ;

  cfg = config.services.displayManager.plasma-login-manager;
  xcfg = config.services.xserver;
  dmcfg = config.services.displayManager;

  iniFmt = pkgs.formats.ini { };

  defaultConfig =
    optionalAttrs xcfg.enable {
      X11.ServerPath = xcfg.displayManager.xserverBin;
    }
    // optionalAttrs dmcfg.autoLogin.enable {
      Autologin = {
        Session = "${dmcfg.sessionData.autologinSession}.desktop";
        User = dmcfg.autoLogin.user;
      };
    };

  defaultConfigFile = iniFmt.generate "00-nixos-defaults.conf" defaultConfig;
  userConfigFile = iniFmt.generate "99-user.conf" cfg.settings;
in
{
  options.services.displayManager.plasma-login-manager = {
    enable = mkEnableOption "Plasma Login Manager";

    package = mkPackageOption pkgs [
      "kdePackages"
      "plasma-login-manager"
    ] { };

    settings = mkOption {
      default = { };
      description = "Additional settings for Plasma Login Manager (see `man plasmalogin.conf`)";

      example = {
        Users.ReuseSession = false;
      };

      type = iniFmt.type;
    };
  };

  config = mkIf cfg.enable {
    environment.etc."plasmalogin.conf.d/00-nixos-defaults.conf".source = defaultConfigFile;
    environment.etc."plasmalogin.conf.d/99-user.conf".source = userConfigFile;
    environment.systemPackages = [ cfg.package ];

    security.pam.services = {
      plasmalogin = {
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

      plasmalogin-autologin = {
        rules = {
          account = utils.pam.autoOrderRules [
            {
              control = "include";
              modulePath = "plasmalogin";
              name = "plasmalogin";
            }
          ];

          auth = utils.pam.autoOrderRules [
            {
              control = "requisite";
              modulePath = "${config.security.pam.package}/lib/security/pam_nologin.so";
              name = "nologin";
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
              modulePath = "plasmalogin";
              name = "plasmalogin";
            }
          ];

          session = utils.pam.autoOrderRules [
            {
              control = "include";
              modulePath = "plasmalogin";
              name = "plasmalogin";
            }
          ];
        };

        useDefaultRules = false;
      };

      plasmalogin-greeter = {
        rules = {
          account = utils.pam.autoOrderRules [
            {
              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_permit.so";
              # No action required for account management
              name = "permit";
            }
          ];

          auth = utils.pam.autoOrderRules [
            {
              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_env.so";
              # Load environment from /etc/environment and ~/.pam_environment
              name = "env";
              settings.conffile = "/etc/pam/environment";
              settings.readenv = 0;
            }
            {
              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_permit.so";
              # Always let the greeter start without authentication
              name = "permit";
            }
          ];

          password = utils.pam.autoOrderRules [
            {
              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_deny.so";
              # Can't change password
              name = "deny";
            }
          ];

          session = utils.pam.autoOrderRules [
            {
              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_unix.so";
              # Setup session
              name = "unix";
            }
            {
              control = "optional";
              modulePath = "${config.systemd.package}/lib/security/pam_systemd.so";
              name = "systemd";
            }
          ];
        };

        useDefaultRules = false;
      };
    };

    services.dbus.packages = [ cfg.package ];
    services.displayManager.enable = true;
    systemd.defaultUnit = "graphical.target";
    systemd.packages = [ cfg.package ];

    systemd.services.plasmalogin = {
      aliases = [ "display-manager.service" ];

      environment.XDG_DATA_DIRS = lib.mkIf (
        dmcfg.sessionPackages != [ ]
      ) "${dmcfg.sessionData.desktops}/share";

      path = [ cfg.package ];
      restartIfChanged = false;
      wantedBy = [ "graphical.target" ];
    };

    systemd.tmpfiles.packages = [ cfg.package ];

    systemd.user.services.plasma-login = {
      environment.XDG_DATA_DIRS = lib.mkIf (
        dmcfg.sessionPackages != [ ]
      ) "${dmcfg.sessionData.desktops}/share";

      overrideStrategy = "asDropin";
    };

    # FIXME: use upstream sysusers
    users = {
      groups.plasmalogin = { };

      users.plasmalogin = {
        description = "Plasma Login Manager greeter user";
        group = "plasmalogin";
        home = "/var/lib/plasmalogin";
        isSystemUser = true;
        name = "plasmalogin";
      };
    };
  };
}
