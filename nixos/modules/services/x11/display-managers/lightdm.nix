{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

with lib;

let

  xcfg = config.services.xserver;
  dmcfg = config.services.displayManager;
  xEnv = config.systemd.services.display-manager.environment;
  cfg = xcfg.displayManager.lightdm;
  sessionData = dmcfg.sessionData;

  setSessionScript = pkgs.callPackage ./account-service-util.nix { };

  inherit (pkgs) lightdm writeScript writeText;

  # lightdm runs with clearenv(), but we need a few things in the environment for X to startup
  xserverWrapper = writeScript "xserver-wrapper" ''
    #! ${pkgs.bash}/bin/bash
    ${concatMapStrings (n: "export ${n}=\"${getAttr n xEnv}\"\n") (attrNames xEnv)}

    display=$(echo "$@" | xargs -n 1 | grep -P ^:\\d\$ | head -n 1 | sed s/^://)
    if [ -z "$display" ]
    then additionalArgs=":0 -logfile /var/log/X.0.log"
    else additionalArgs="-logfile /var/log/X.$display.log"
    fi

    exec ${xcfg.displayManager.xserverBin} ${toString xcfg.displayManager.xserverArgs} $additionalArgs "$@"
  '';

  usersConf = writeText "users.conf" ''
    [UserList]
    minimum-uid=1000
    hidden-users=${concatStringsSep " " dmcfg.hiddenUsers}
    hidden-shells=/run/current-system/sw/bin/nologin
  '';

  lightdmConf = writeText "lightdm.conf" ''
    [LightDM]
    minimum-vt = 1
    ${optionalString cfg.greeter.enable ''
      greeter-user = ${config.users.users.lightdm.name}
      greeters-directory = ${cfg.greeter.package}
    ''}
    sessions-directory = ${dmcfg.sessionData.desktops}/share/xsessions:${dmcfg.sessionData.desktops}/share/wayland-sessions
    ${cfg.extraConfig}

    [Seat:*]
    xserver-command = ${xserverWrapper}
    session-wrapper = ${dmcfg.sessionData.wrapper}
    ${optionalString cfg.greeter.enable ''
      greeter-session = ${cfg.greeter.name}
    ''}
    ${optionalString dmcfg.autoLogin.enable ''
      autologin-user = ${dmcfg.autoLogin.user}
      autologin-user-timeout = ${toString cfg.autoLogin.timeout}
      autologin-session = ${sessionData.autologinSession}
    ''}
    ${optionalString (xcfg.displayManager.setupCommands != "") ''
      display-setup-script=${pkgs.writeScript "lightdm-display-setup" ''
        #!${pkgs.bash}/bin/bash
        ${xcfg.displayManager.setupCommands}
      ''}
    ''}
    ${cfg.extraSeatDefaults}
  '';

in
{
  # Note: the order in which lightdm greeter modules are imported
  # here determines the default: later modules (if enable) are
  # preferred.
  imports = [
    ./lightdm-greeters/gtk.nix
    ./lightdm-greeters/mini.nix
    ./lightdm-greeters/enso-os.nix
    ./lightdm-greeters/pantheon.nix
    ./lightdm-greeters/lomiri.nix
    ./lightdm-greeters/tiny.nix
    ./lightdm-greeters/slick.nix
    ./lightdm-greeters/mobile.nix
    (mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "lightdm" "autoLogin" "enable" ]
      [
        "services"
        "displayManager"
        "autoLogin"
        "enable"
      ]
    )
    (mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "lightdm" "autoLogin" "user" ]
      [
        "services"
        "displayManager"
        "autoLogin"
        "user"
      ]
    )
  ];

  options = {

    services.xserver.displayManager.lightdm = {

      enable = mkOption {
        default = false;

        description = ''
          Whether to enable lightdm as the display manager.
        '';

        type = types.bool;
      };

      # Configuration for automatic login specific to LightDM
      autoLogin.timeout = mkOption {
        default = 0;

        description = ''
          Show the greeter for this many seconds before automatic login occurs.
        '';

        type = types.int;
      };

      background = mkOption {
        # Manual cannot depend on packages, we are actually setting the default in config below.
        defaultText = literalExpression "pkgs.nixos-artwork.wallpapers.simple-dark-gray-bottom.gnomeFilePath";

        description = ''
          The background image or color to use.
        '';

        type = types.either types.path (types.strMatching "^#[0-9A-Fa-f]{6}$");
      };

      extraConfig = mkOption {
        default = "";
        description = "Extra lines to append to LightDM section.";

        example = ''
          user-authority-in-system-dir = true
        '';

        type = types.lines;
      };

      extraSeatDefaults = mkOption {
        default = "";
        description = "Extra lines to append to SeatDefaults section.";

        example = ''
          greeter-show-manual-login=true
        '';

        type = types.lines;
      };

      greeter = {
        enable = mkOption {
          default = true;

          description = ''
            If set to false, run lightdm in greeterless mode. This only works if autologin
            is enabled and autoLogin.timeout is zero.
          '';

          type = types.bool;
        };

        package = mkOption {
          description = ''
            The LightDM greeter to login via. The package should be a directory
            containing a .desktop file matching the name in the 'name' option.
          '';

          type = types.package;

        };

        name = mkOption {
          description = ''
            The name of a .desktop file in the directory specified
            in the 'package' option.
          '';

          type = types.str;
        };
      };

    };
  };

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion = xcfg.enable;

        message = ''
          LightDM requires services.xserver.enable to be true
        '';
      }
      {
        assertion = dmcfg.autoLogin.enable -> sessionData.autologinSession != null;

        message = ''
          LightDM auto-login requires that services.displayManager.defaultSession is set.
        '';
      }
      {
        assertion = !cfg.greeter.enable -> (dmcfg.autoLogin.enable && cfg.autoLogin.timeout == 0);

        message = ''
          LightDM can only run without greeter if automatic login is enabled and the timeout for it
          is set to zero.
        '';
      }
    ];

    environment.etc."lightdm/lightdm.conf".source = lightdmConf;
    environment.etc."lightdm/users.conf".source = usersConf;
    # Enable the accounts daemon to find lightdm's dbus interface
    environment.systemPackages = [ lightdm ];

    security.pam.services.lightdm = {
      rules = {
        account = utils.pam.autoOrderRules [
          {
            control = "include";
            modulePath = "login";
            name = "login";
          }
          {
            # https://github.com/elementary/switchboard-plug-parental-controls/blob/8.0.1/src/daemon/Server.vala#L325
            enable = config.services.pantheon.parental-controls.enable;
            control = "required";
            modulePath = "${config.security.pam.package}/lib/security/pam_time.so";
            name = "time";
            # Must specify conffile since pam_time defaults to ${linux-pam}/etc/security/time.conf.
            settings.conffile = "/etc/security/time.conf";
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

    security.pam.services.lightdm-autologin = {
      rules = {
        account = utils.pam.autoOrderRules [
          {
            control = "sufficient";
            modulePath = "${config.security.pam.package}/lib/security/pam_unix.so";
            name = "unix";
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
            name = "lightdm-normal-user";
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
            control = "requisite";
            modulePath = "${config.security.pam.package}/lib/security/pam_unix.so";
            name = "unix";
            settings.nullok = true;
            settings.yescrypt = true;
          }
        ];

        session = utils.pam.autoOrderRules [
          {
            control = "optional";
            modulePath = "${config.security.pam.package}/lib/security/pam_keyinit.so";
            name = "keyinit";
            settings.revoke = true;
          }
          {
            control = "include";
            modulePath = "login";
            name = "login";
          }
        ];
      };

      useDefaultRules = false;
    };

    security.pam.services.lightdm-greeter = {
      rules = {
        account = utils.pam.autoOrderRules [
          {
            args = lib.mkAfter [
              "user"
              "="
              "lightdm"
            ];

            control = "required";
            modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
            name = "lightdm-user";
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
              "lightdm"
            ];

            control = "required";
            modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
            name = "lightdm-user";
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
              "lightdm"
            ];

            control = "required";
            modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
            name = "lightdm-user";
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

    security.polkit.enable = true;
    # lightdm uses the accounts daemon to remember language/window-manager per user
    services.accounts-daemon.enable = true;
    services.dbus.enable = true;
    services.dbus.packages = [ lightdm ];
    services.displayManager.generic.enable = true;
    # setSessionScript needs session-files in XDG_DATA_DIRS
    services.displayManager.generic.environment.XDG_DATA_DIRS = "${dmcfg.sessionData.desktops}/share/";

    # lightdm relaunches itself via just `lightdm`, so needs to be on the PATH
    services.displayManager.generic.execCmd = ''
      export PATH=${lightdm}/sbin:$PATH
      exec ${lightdm}/sbin/lightdm
    '';

    # Set default session in session chooser to a specified values – basically ignore session history.
    # Auto-login is already covered by a config value.
    services.displayManager.generic.preStart =
      optionalString (!dmcfg.autoLogin.enable && dmcfg.defaultSession != null)
        ''
          ${setSessionScript}/bin/set-session ${dmcfg.defaultSession}
        '';

    services.xserver.display = null; # We specify our own display (and logfile) in xserver-wrapper up there

    # Keep in sync with the defaultText value from the option definition.
    services.xserver.displayManager.lightdm.background =
      mkDefault pkgs.nixos-artwork.wallpapers.simple-dark-gray-bottom.gnomeFilePath;

    # Pull in dependencies of services we replace.
    systemd.services.display-manager.after = [
      "rc-local.service"
      "systemd-machined.service"
      "systemd-user-sessions.service"
      "user.slice"
    ];

    # lightdm stops plymouth so when it fails make sure plymouth stops.
    systemd.services.display-manager.onFailure = [
      "plymouth-quit.service"
    ];

    # user.slice needs to be present
    systemd.services.display-manager.requires = [
      "user.slice"
    ];

    systemd.services.display-manager.serviceConfig = {
      BusName = "org.freedesktop.DisplayManager";
      IgnoreSIGPIPE = "no";
      # This allows lightdm to pass the LUKS password through to PAM.
      # login keyring is unlocked automatic when autologin is used.
      KeyringMode = "shared";
      KillMode = "mixed";
      StandardError = "inherit";
    };

    # setSessionScript wants AccountsService
    systemd.services.display-manager.wants = [
      "accounts-daemon.service"
    ];

    systemd.tmpfiles.rules = [
      "d /run/lightdm 0711 lightdm lightdm -"
      "d /var/cache/lightdm 0711 root lightdm -"
      "d /var/lib/lightdm 1770 lightdm lightdm -"
      "d /var/lib/lightdm-data 1775 lightdm lightdm -"
      "d /var/log/lightdm 0711 root lightdm -"
    ];

    users.groups.lightdm.gid = config.ids.gids.lightdm;

    users.users.lightdm = {
      group = "lightdm";
      home = "/var/lib/lightdm";
      uid = config.ids.uids.lightdm;
    };
  };

  meta = {
    teams = [ lib.teams.pantheon ];
  };
}
