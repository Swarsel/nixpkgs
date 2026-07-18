{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let

  cfg = config.services.displayManager.gdm;
  gdm = pkgs.gdm;
  xdmcfg = config.services.xserver.displayManager;
  pamLogin = config.security.pam.services.login;
  settingsFormat = pkgs.formats.ini { };
  configFile = settingsFormat.generate "custom.conf" cfg.settings;

  xSessionWrapper =
    if (xdmcfg.setupCommands == "") then
      null
    else
      pkgs.writeScript "gdm-x-session-wrapper" ''
        #!${pkgs.bash}/bin/bash
        ${xdmcfg.setupCommands}
        exec "$@"
      '';

  # Solves problems like:
  # https://wiki.archlinux.org/index.php/Talk:Bluetooth_headset#GDMs_pulseaudio_instance_captures_bluetooth_headset
  # Instead of blacklisting plugins, we use Fedora's PulseAudio configuration for GDM:
  # https://src.fedoraproject.org/rpms/gdm/blob/master/f/default.pa-for-gdm
  pulseConfig = pkgs.writeText "default.pa" ''
    load-module module-device-restore
    load-module module-card-restore
    load-module module-udev-detect
    load-module module-native-protocol-unix
    load-module module-default-device-restore
    load-module module-always-sink
    load-module module-intended-roles
    load-module module-suspend-on-idle
    load-module module-position-event-sounds
  '';

  defaultSessionName = config.services.displayManager.defaultSession;

  setSessionScript = pkgs.callPackage ../x11/display-managers/account-service-util.nix { };

  greeterUsers = lib.genAttrs' [ null 1 2 3 4 ] (
    i:
    let
      # adding 1 to create `gdm-greeter{-2,-3,-4,-5}`
      suffix = lib.optionalString (i != null) "-${toString (i + 1)}";
    in
    lib.nameValuePair "gdm-greeter${suffix}" {
      group = "gdm";
      home = "/run/gdm/home/gdm-greeter${suffix}";
      isSystemUser = true;
      uid = 60578 + (if i == null then 0 else i);
    }
  );
in

{
  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "gdm" "autoLogin" "enable" ]
      [
        "services"
        "displayManager"
        "autoLogin"
        "enable"
      ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "gdm" "autoLogin" "user" ]
      [
        "services"
        "displayManager"
        "autoLogin"
        "user"
      ]
    )

    (lib.mkRemovedOptionModule [
      "services"
      "xserver"
      "displayManager"
      "gdm"
      "nvidiaWayland"
    ] "We defer to GDM whether Wayland should be enabled.")

    (lib.mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "gdm" "enable" ]
      [ "services" "displayManager" "gdm" "enable" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "gdm" "debug" ]
      [ "services" "displayManager" "gdm" "debug" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "gdm" "banner" ]
      [ "services" "displayManager" "gdm" "banner" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "gdm" "settings" ]
      [ "services" "displayManager" "gdm" "settings" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "gdm" "wayland" ]
      [ "services" "displayManager" "gdm" "wayland" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "gdm" "autoSuspend" ]
      [ "services" "displayManager" "gdm" "autoSuspend" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "xserver" "displayManager" "gdm" "autoLogin" "delay" ]
      [ "services" "displayManager" "gdm" "autoLogin" "delay" ]
    )
    (lib.mkRemovedOptionModule [
      "services"
      "displayManager"
      "gdm"
      "wayland"
    ] "Disabling this option is no longer supported with GNOME 50.")
  ];

  ###### interface
  options = {

    services.displayManager.gdm = {

      enable = lib.mkEnableOption "GDM, the GNOME Display Manager";

      # Auto login options specific to GDM
      autoLogin.delay = lib.mkOption {
        default = 0;

        description = ''
          Seconds of inactivity after which the autologin will be performed.
        '';

        type = lib.types.int;
      };

      autoSuspend = lib.mkOption {
        default = true;

        description = ''
          On the GNOME Display Manager login screen, suspend the machine after inactivity.
          (Does not affect automatic suspend while logged in, or at lock screen.)
        '';

        type = lib.types.bool;
      };

      banner = lib.mkOption {
        default = null;

        description = ''
          Optional message to display on the login screen.
        '';

        example = ''
          foo
          bar
          baz
        '';

        type = lib.types.nullOr lib.types.lines;
      };

      debug = lib.mkEnableOption "debugging messages in GDM";

      extraPackages = lib.mkOption {
        default = [ ];

        description = ''
          Additional packages to add to XDG_DATA_DIRS for GDM.
          The `/share` directory of each package will be added to the data path.
        '';

        example = lib.literalExpression "[ pkgs.gnome-themes-extra ]";
        type = lib.types.listOf lib.types.package;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Options passed to the gdm daemon.
          See [here](https://help.gnome.org/admin/gdm/stable/configuration.html.en#daemonconfig) for supported options.
        '';

        example = {
          debug.enable = true;
        };

        type = settingsFormat.type;
      };

    };

  };

  ###### implementation
  config = lib.mkIf cfg.enable {

    environment.etc."gdm/Xsession".source = config.services.displayManager.sessionData.wrapper;
    environment.etc."gdm/custom.conf".source = configFile;

    environment.systemPackages = [
      pkgs.adwaita-icon-theme
      pkgs.gdm # For polkit rules
    ];

    programs.dconf.profiles.gdm.databases =
      lib.optionals (!cfg.autoSuspend) [
        {
          settings."org/gnome/settings-daemon/plugins/power" = {
            sleep-inactive-ac-timeout = lib.gvariant.mkInt32 0;
            sleep-inactive-ac-type = "nothing";
            sleep-inactive-battery-timeout = lib.gvariant.mkInt32 0;
            sleep-inactive-battery-type = "nothing";
          };
        }
      ]
      ++ lib.optionals (cfg.banner != null) [
        {
          settings."org/gnome/login-screen" = {
            banner-message-enable = true;
            banner-message-text = cfg.banner;
          };
        }
      ]
      ++ [ "${gdm}/share/gdm/greeter-dconf-defaults" ];

    # GDM LFS PAM modules, adapted somehow to NixOS
    security.pam.services = {
      gdm-autologin = {
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
              name = "gdm-normal-user";
              settings.quiet = true;
            }
            {
              enable = pamLogin.enable && pamLogin.enableGnomeKeyring;
              control = "[success=ok default=1]";
              modulePath = "${gdm}/lib/security/pam_gdm.so";
              name = "gdm";
            }
            {
              enable = pamLogin.enable && pamLogin.enableGnomeKeyring;
              control = "optional";
              modulePath = "${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so";
              name = "gnome_keyring";
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

      gdm-fingerprint = lib.mkIf config.services.fprintd.enable {
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
              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_shells.so";
              name = "shells";
            }
            {
              control = "requisite";
              modulePath = "${config.security.pam.package}/lib/security/pam_nologin.so";
              name = "nologin";
            }
            {
              control = "requisite";
              modulePath = "${config.security.pam.package}/lib/security/pam_faillock.so";
              name = "faillock";
              settings.preauth = true;
            }
            {
              control = "required";
              modulePath = "${pkgs.fprintd}/lib/security/pam_fprintd.so";
              name = "fprintd";
            }
            {
              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_env.so";
              name = "env";
              settings.conffile = "/etc/pam/environment";
              settings.readenv = 0;
            }
            {
              enable = pamLogin.enable && pamLogin.enableGnomeKeyring;
              control = "[success=ok default=1]";
              modulePath = "${gdm}/lib/security/pam_gdm.so";
              name = "gdm";
            }
            {
              enable = pamLogin.enable && pamLogin.enableGnomeKeyring;
              control = "optional";
              modulePath = "${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so";
              name = "gnome_keyring";
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
              control = "include";
              modulePath = "login";
              name = "login";
            }
          ];
        };

        useDefaultRules = false;
      };

      gdm-launch-environment = {
        rules = {
          account = utils.pam.autoOrderRules [
            {
              args = lib.mkAfter [
                "user"
                "ingroup"
                "gdm"
              ];

              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
              name = "gdm-user";
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
                "ingroup"
                "gdm"
              ];

              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
              name = "gdm-user";
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
                "ingroup"
                "gdm"
              ];

              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
              name = "gdm-user";
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
            # make sure the spawned session has the same variables as `display-manager.service`
            # https://github.com/NixOS/nixpkgs/issues/523332
            {
              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_env.so";
              name = "env-greeter";

              settings.conffile =
                let
                  env = config.services.displayManager.generic.environment;
                in
                pkgs.writeText "gdm-launch-environment-env-conf" ''
                  PATH          DEFAULT="''${PATH}:${pkgs.gnome-session}/bin"
                  XDG_DATA_DIRS DEFAULT="''${XDG_DATA_DIRS}:${env.XDG_DATA_DIRS}"
                '';

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

      gdm-password = {
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

      # This would block password prompt when included by gdm-password.
      # GDM will instead run gdm-fingerprint in parallel.
      login.fprintAuth = lib.mkIf config.services.fprintd.enable false;
    };

    # Allow choosing an user account
    services.accounts-daemon.enable = true;
    services.dbus.packages = [ gdm ];

    services.displayManager = {
      # Enable desktop session data
      enable = true;

      generic = {
        enable = true;

        environment = {
          GDM_X_SERVER_EXTRA_ARGS = toString (lib.filter (arg: arg != "-terminate") xdmcfg.xserverArgs);

          XDG_DATA_DIRS = lib.makeSearchPath "share" (
            [
              gdm # for gnome-login.session
              config.services.displayManager.sessionData.desktops
              pkgs.gnome-control-center # for accessibility icon
              pkgs.adwaita-icon-theme
              pkgs.hicolor-icon-theme # empty icon theme as a base
            ]
            ++ cfg.extraPackages
          );
        }
        // lib.optionalAttrs (xSessionWrapper != null) {
          # Make GDM use this wrapper before running the session, which runs the
          # configured setupCommands. This relies on a patched GDM which supports
          # this environment variable.
          GDM_X_SESSION_WRAPPER = "${xSessionWrapper}";
        };

        execCmd = "exec ${gdm}/bin/gdm";

        preStart = lib.optionalString (defaultSessionName != null) ''
          # Set default session in session chooser to a specified values – basically ignore session history.
          ${setSessionScript}/bin/set-session ${config.services.displayManager.sessionData.autologinSession}
        '';
      };
    };

    # Use AutomaticLogin if delay is zero, because it's immediate.
    # Otherwise with TimedLogin with zero seconds the prompt is still
    # presented and there's a little delay.
    services.displayManager.gdm.settings = {
      daemon = lib.mkMerge [
        # nested if else didn't work
        (lib.mkIf (config.services.displayManager.autoLogin.enable && cfg.autoLogin.delay != 0) {
          TimedLogin = config.services.displayManager.autoLogin.user;
          TimedLoginDelay = cfg.autoLogin.delay;
          TimedLoginEnable = true;
        })
        (lib.mkIf (config.services.displayManager.autoLogin.enable && cfg.autoLogin.delay == 0) {
          AutomaticLogin = config.services.displayManager.autoLogin.user;
          AutomaticLoginEnable = true;
        })
      ];

      debug = lib.mkIf cfg.debug {
        Enable = true;
      };
    };

    # GDM needs different xserverArgs, presumable because using wayland by default.
    services.xserver.display = null;
    services.xserver.displayManager.lightdm.enable = false;
    services.xserver.verbose = null;

    # Otherwise GDM will not be able to start correctly and display Wayland sessions
    systemd.packages = [
      gdm
      pkgs.gnome-session
      pkgs.gnome-shell
    ];

    systemd.services.display-manager.after = [
      "rc-local.service"
      "systemd-machined.service"
      "systemd-user-sessions.service"
      "plymouth-quit.service"
      "plymouth-start.service"
    ];

    systemd.services.display-manager.conflicts = [
      "plymouth-quit.service"
    ];

    systemd.services.display-manager.onFailure = [
      "plymouth-quit.service"
    ];

    systemd.services.display-manager.path = [ pkgs.gnome-session ];

    systemd.services.display-manager.serviceConfig = {
      BusName = "org.gnome.DisplayManager";
      EnvironmentFile = "-/etc/locale.conf";
      ExecReload = "${pkgs.coreutils}/bin/kill -SIGHUP $MAINPID";
      IgnoreSIGPIPE = "no";
      KeyringMode = "shared";
      # Restart = "always"; - already defined in xserver.nix
      KillMode = "mixed";
      StandardError = "inherit";
    };

    systemd.services.display-manager.wants = [
      # Because sd_login_monitor_new requires /run/systemd/machines
      "systemd-machined.service"
      # setSessionScript wants AccountsService
      "accounts-daemon.service"
    ];

    # We dont use the upstream gdm service
    # it has to be disabled since the gdm package has it
    # https://github.com/NixOS/nixpkgs/issues/108672
    systemd.services.gdm.enable = false;

    # Prevent nixos-rebuild switch from bringing down the graphical
    # session. (If multi-user.target wants plymouth-quit.service which
    # conflicts display-manager.service, then when nixos-rebuild
    # switch starts multi-user.target, display-manager.service is
    # stopped so plymouth-quit.service can be started.)
    systemd.services.plymouth-quit = lib.mkIf config.boot.plymouth.enable {
      wantedBy = lib.mkForce [ ];
    };

    systemd.tmpfiles.rules =
      lib.optionals config.services.pulseaudio.enable (
        lib.concatLists (
          lib.mapAttrsToList (name: user: [
            "d ${user.home}/.config 0711 ${name} gdm"
            "d ${user.home}/.config/pulse 0711 ${name} gdm"
            "L+ ${user.home}/.config/pulse/${pulseConfig.name} - - - - ${pulseConfig}"
          ]) greeterUsers
        )
      )
      ++ lib.optionals config.services.gnome.gnome-initial-setup.enable [
        # Create stamp file for gnome-initial-setup to prevent it starting in GDM.
        "f /run/gdm/gdm.ran-initial-setup 0711 gdm gdm - yes"
      ];

    systemd.user.services.dbus.wantedBy = [ "default.target" ];
    users.groups.gdm.gid = config.ids.gids.gdm;

    users.users = lib.mkMerge [
      {
        gdm = {
          description = "GDM user";
          group = "gdm";
          name = "gdm";
          uid = config.ids.uids.gdm;
        };
      }
      greeterUsers
    ];

  };

  meta = {
    teams = [ lib.teams.gnome ];
  };

}
