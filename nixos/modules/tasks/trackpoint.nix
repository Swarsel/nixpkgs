{
  config,
  lib,
  ...
}:
{
  options = {
    hardware.trackpoint = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Enable sensitivity and speed configuration for trackpoints.
        '';

        type = lib.types.bool;
      };

      device = lib.mkOption {
        default = "TPPS/2 IBM TrackPoint";

        description = ''
          The device name of the trackpoint. You can check with xinput.
          Some newer devices (example x1c6) use "TPPS/2 Elan TrackPoint".
        '';

        type = lib.types.str;
      };

      draghys = lib.mkOption {
        default = 255;

        description = ''
          The drag hysteresis controls how hard it is to drag with z-axis pressed.
        '';

        example = 200;
        type = lib.types.int;
      };

      drift_time = lib.mkOption {
        default = 5;

        description = ''
          This parameter controls the period of time to test for a 'hands off' condition (i.e. when no force is applied) before a drift (noise) calibration occurs.

          IBM Trackpoints have a feature to compensate for drift by recalibrating themselves periodically. By default, if for 0.5 seconds there is no change in position, it's used as the new zero. This duration is too low. Often, the calibration happens when the trackpoint is in fact being used.
        '';

        example = 100;
        type = lib.types.int;
      };

      emulateWheel = lib.mkOption {
        default = false;

        description = ''
          Enable scrolling while holding the middle mouse button.
        '';

        type = lib.types.bool;
      };

      ext_dev = lib.mkOption {
        default = true;

        description = ''
          Disable or enable external pointing device.
        '';

        example = false;
        type = lib.types.bool;
      };

      fakeButtons = lib.mkOption {
        default = false;

        description = ''
          Switch to "bare" PS/2 mouse support in case Trackpoint buttons are not recognized
          properly. This can happen for example on models like the L430, T450, T450s, on
          which the Trackpoint buttons are actually a part of the Synaptics touchpad.
        '';

        type = lib.types.bool;
      };

      inertia = lib.mkOption {
        default = 6;

        description = ''
          Negative inertia factor. High values cause the cursor to snap backward when the trackpoint is released.
        '';

        example = 10;
        type = lib.types.int;
      };

      jenks = lib.mkOption {
        default = 135;

        description = ''
          Minimum curvature in degrees required to generate a double click without a release.
        '';

        example = 100;
        type = lib.types.int;
      };

      mindrag = lib.mkOption {
        default = 20;

        description = ''
          Minimum amount of force needed to trigger dragging.
        '';

        example = 30;
        type = lib.types.int;
      };

      press_to_select = lib.mkOption {
        default = false;

        description = ''
          Setting this to true will enable the Press to Select functions like tapping the control stick to simulate a left click, and setting false will disable it.
        '';

        example = true;
        type = lib.types.bool;
      };

      reach = lib.mkOption {
        default = 10;

        description = ''
          Backup range for z-axis press.
        '';

        example = 20;
        type = lib.types.int;
      };

      sensitivity = lib.mkOption {
        default = 128;

        description = ''
          Trackpoint sensitivity.
        '';

        example = 255;
        type = lib.types.int;
      };

      skipback = lib.mkOption {
        default = false;

        description = ''
          When the skipback bit is set, backup cursor movement during releases from drags will be suppressed. The default value for this bit is 0.
        '';

        example = true;
        type = lib.types.bool;
      };

      speed = lib.mkOption {
        default = 97;

        description = ''
          Speed of the trackpoint cursor.
        '';

        example = 255;
        type = lib.types.int;
      };

      thresh = lib.mkOption {
        default = 8;

        description = ''
          Minimum value for z-axis force required to trigger a press or release, relative to the running average.
        '';

        example = 10;
        type = lib.types.int;
      };

      upthresh = lib.mkOption {
        default = 255;

        description = ''
          The offset from the running average required to generate a select (click) on z-axis on release.
        '';

        example = 250;
        type = lib.types.int;
      };

      ztime = lib.mkOption {
        default = 38;

        description = ''
          This attribute determines how sharp a press has to be in order to be recognized.
        '';

        example = 50;
        type = lib.types.int;
      };
    };
  };

  config =
    let
      cfg = config.hardware.trackpoint;
      boolToStr = val: if val then "1" else "0";
    in
    lib.mkMerge [
      (lib.mkIf cfg.enable {
        services.udev.extraRules = (
          builtins.concatStringsSep ", " [
            "ACTION==\"add|change\""
            "SUBSYSTEM==\"input\""
            "ATTR{name}==\"${cfg.device}\""
            "ATTR{device/sensitivity}=\"${toString cfg.sensitivity}\""
            "ATTR{device/inertia}=\"${toString cfg.inertia}\""
            "ATTR{device/reach}=\"${toString cfg.reach}\""
            "ATTR{device/draghys}=\"${toString cfg.draghys}\""
            "ATTR{device/mindrag}=\"${toString cfg.mindrag}\""
            "ATTR{device/speed}=\"${toString cfg.speed}\""
            "ATTR{device/thresh}=\"${toString cfg.thresh}\""
            "ATTR{device/upthresh}=\"${toString cfg.upthresh}\""
            "ATTR{device/ztime}=\"${toString cfg.ztime}\""
            "ATTR{device/jenks}=\"${toString cfg.jenks}\""
            "ATTR{device/skipback}=\"${boolToStr cfg.skipback}\""
            "ATTR{device/ext_dev}=\"${boolToStr cfg.ext_dev}\""
            "ATTR{device/press_to_select}=\"${boolToStr cfg.press_to_select}\""
            "ATTR{device/drift_time}=\"${toString cfg.drift_time}\""
          ]
        );

        systemd.services.trackpoint = {
          before = [
            "sysinit.target"
            "shutdown.target"
          ];

          conflicts = [ "shutdown.target" ];

          serviceConfig.ExecStart = ''
            ${config.systemd.package}/bin/udevadm trigger --attr-match=name="${cfg.device}"
          '';

          serviceConfig.RemainAfterExit = true;
          serviceConfig.Type = "oneshot";
          unitConfig.DefaultDependencies = false;
          wantedBy = [ "sysinit.target" ];
        };
      })

      (lib.mkIf (cfg.emulateWheel) {
        services.xserver.inputClassSections = [
          ''
            Identifier "Trackpoint Wheel Emulation"
            MatchProduct "${
              if cfg.fakeButtons then
                "PS/2 Generic Mouse"
              else
                "ETPS/2 Elantech TrackPoint|Elantech PS/2 TrackPoint|TPPS/2 IBM TrackPoint|DualPoint Stick|Synaptics Inc. Composite TouchPad / TrackPoint|ThinkPad USB Keyboard with TrackPoint|USB Trackpoint pointing device|Composite TouchPad / TrackPoint|${cfg.device}"
            }"
            MatchDevicePath "/dev/input/event*"
            Option "EmulateWheel" "true"
            Option "EmulateWheelButton" "2"
            Option "Emulate3Buttons" "false"
            Option "XAxisMapping" "6 7"
            Option "YAxisMapping" "4 5"
          ''
        ];
      })

      (lib.mkIf cfg.fakeButtons {
        boot.extraModprobeConfig = "options psmouse proto=bare";
      })
    ];
}
