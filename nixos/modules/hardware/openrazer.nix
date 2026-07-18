{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.openrazer;

  toPyBoolStr = b: if b then "True" else "False";

  daemonExe = "${cfg.packages.daemon}/bin/openrazer-daemon --config ${daemonConfFile}";

  daemonConfFile = pkgs.writeTextFile {
    name = "razer.conf";

    text = ''
      [General]
      verbose_logging = ${toPyBoolStr cfg.verboseLogging}

      [Startup]
      sync_effects_enabled = ${toPyBoolStr cfg.syncEffectsEnabled}
      devices_off_on_screensaver = ${toPyBoolStr cfg.devicesOffOnScreensaver}
      battery_notifier = ${toPyBoolStr cfg.batteryNotifier.enable}
      battery_notifier_freq = ${toString cfg.batteryNotifier.frequency}
      battery_notifier_percent = ${toString cfg.batteryNotifier.percentage}

      [Statistics]
      key_statistics = ${toPyBoolStr cfg.keyStatistics}
    '';
  };

  dbusServiceFile = pkgs.writeTextFile rec {
    destination = "/share/dbus-1/services/${name}";
    name = "org.razer.service";

    text = ''
      [D-BUS Service]
      Name=org.razer
      Exec=${daemonExe}
      SystemdService=openrazer-daemon.service
    '';
  };

  drivers = [
    "razerkbd"
    "razermouse"
    "razerkraken"
    "razeraccessory"
  ];
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "hardware" "openrazer" "mouseBatteryNotifier" ]
      [ "hardware" "openrazer" "batteryNotifier" "enable" ]
    )
  ];

  options = {
    hardware.openrazer = {
      enable = lib.mkEnableOption ''
        OpenRazer drivers and userspace daemon
      '';

      batteryNotifier = lib.mkOption {
        default = { };

        description = ''
          Settings for device battery notifications.
        '';

        type = lib.types.submodule {
          options = {
            enable = lib.mkOption {
              default = true;

              description = ''
                Mouse battery notifier.
              '';

              type = lib.types.bool;
            };

            frequency = lib.mkOption {
              default = 600;

              description = ''
                How often battery notifications should be shown (in seconds).
                A value of 0 disables notifications.
              '';

              type = lib.types.int;
            };

            percentage = lib.mkOption {
              default = 33;

              description = ''
                At what battery percentage the device should reach before
                sending notifications.
              '';

              type = lib.types.int;
            };
          };
        };
      };

      devicesOffOnScreensaver = lib.mkOption {
        default = true;

        description = ''
          Turn off the devices when the systems screensaver kicks in.
        '';

        type = lib.types.bool;
      };

      keyStatistics = lib.mkOption {
        default = false;

        description = ''
          Collects number of keypresses per hour per key used to
          generate a heatmap.
        '';

        type = lib.types.bool;
      };

      packages = {
        daemon = lib.mkPackageOption pkgs [ "python3Packages" "openrazer-daemon" ] { };

        kernel = lib.mkPackageOption pkgs "openrazer kernel" { } // {
          default = config.boot.kernelPackages.openrazer;
          defaultText = lib.literalExpression "config.boot.kernelPackages.openrazer";
        };
      };

      syncEffectsEnabled = lib.mkOption {
        default = true;

        description = ''
          Set the sync effects flag to true so any assignment of
          effects will work across devices.
        '';

        type = lib.types.bool;
      };

      users = lib.mkOption {
        default = [ ];

        description = ''
          Usernames to be added to the "openrazer" group, so that they
          can start and interact with the OpenRazer userspace daemon.
        '';

        type = with lib.types; listOf str;
      };

      verboseLogging = lib.mkOption {
        default = false;

        description = ''
          Whether to enable verbose logging. Logs debug messages.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [ cfg.packages.kernel ];
    boot.kernelModules = drivers;

    # Makes the man pages available so you can successfully run
    # > systemctl --user help openrazer-daemon
    environment.systemPackages = lib.mkIf (cfg.packages.daemon ? man) [
      cfg.packages.daemon.man
    ];

    services.dbus.packages = [ dbusServiceFile ];
    services.udev.packages = [ cfg.packages.kernel ];

    systemd.user.services.openrazer-daemon = {
      description = "Daemon to manage razer devices in userspace";
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        BusName = "org.razer";
        ExecStart = "${daemonExe} --foreground";
        Restart = "always";
        Type = "dbus";
      };

      unitConfig.Documentation = "man:openrazer-daemon(8)";
      # Requires a graphical session so the daemon knows when the screensaver
      # starts. See the 'devicesOffOnScreensaver' option.
      wantedBy = [ "graphical-session.target" ];
    };

    # A user must be a member of the openrazer group in order to start
    # the openrazer-daemon. Therefore we make sure that the group
    # exists.
    users.groups.openrazer = {
      members = cfg.users;
    };
  };
}
