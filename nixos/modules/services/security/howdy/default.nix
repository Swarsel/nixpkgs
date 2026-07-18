{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.howdy;
  settingsType = pkgs.formats.ini { };

  default_config = {
    core = {
      abort_if_lid_closed = true;
      abort_if_ssh = true;
      detection_notice = false;
      disabled = false;
      no_confirmation = false;
      suppress_unknown = false;
      timeout_notice = true;
      use_cnn = false;
      workaround = "off";
    };

    debug = {
      end_report = false;
      gtk_stdout = false;
      verbose_stamps = false;
    };

    rubberstamps = {
      enabled = false;
      stamp_rules = "nod		5s		failsafe     min_distance=12";
    };

    snapshots = {
      save_failed = false;
      save_successful = false;
    };

    video = {
      certainty = 3.5;
      dark_threshold = 60;
      device_format = "v4l2";
      device_fps = -1;
      device_path = "/dev/video2";
      exposure = -1;
      force_mjpeg = false;
      frame_height = -1;
      frame_width = -1;
      max_height = 320;
      recording_plugin = "opencv";
      rotate = 0;
      timeout = 4;
      warn_no_device = true;
    };
  };
in
{
  options = {
    services.howdy = {
      enable = lib.mkEnableOption "" // {
        description = ''
          Whether to enable Howdy and its PAM module for face recognition. See
          `services.linux-enable-ir-emitter` for enabling the IR emitter support.

          ::: {.caution}
          Howdy is not a safe alternative to unlocking with your password. It
          can be fooled using a well-printed photo.

          Do **not** use it as the sole authentication method for your system.
          :::

          ::: {.note}
          By default, the {option}`config.services.howdy.control` option is set
          to `"required"`, meaning it will act as a second-factor authentication
          in most services. To change this, set the option to `"sufficient"`.
          :::
        '';
      };

      package = lib.mkPackageOption pkgs "howdy" { };

      control = lib.mkOption {
        default = "required";

        description = ''
          PAM control flag to use for Howdy.

          Sets the {option}`security.pam.howdy.control` option.

          Refer to {manpage}`pam.conf(5)` for options.
        '';

        type = lib.types.str;
      };

      settings = lib.mkOption {
        inherit (settingsType) type;
        default = default_config;

        description = ''
          Howdy configuration file. Refer to
          <https://github.com/boltgolt/howdy/blob/d3ab99382f88f043d15f15c1450ab69433892a1c/howdy/src/config.ini>
          for options.
        '';
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = !(builtins.elem "v4l2loopback" config.boot.kernelModules);
          message = "Adding 'v4l2loopback' to `boot.kernelModules` causes Howdy to no longer work. Consider adding 'v4l2loopback' to `boot.extraModulePackages` instead.";
        }
      ];

      environment.etc."howdy/config.ini".source = settingsType.generate "howdy-config.ini" cfg.settings;
      environment.systemPackages = [ cfg.package ];
    })
    {
      services.howdy.settings = lib.mapAttrsRecursive (name: lib.mkDefault) default_config;
    }
  ];
}
