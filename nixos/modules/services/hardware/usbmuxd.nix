{
  config,
  lib,
  pkgs,
  ...
}:
let

  defaultUserGroup = "usbmux";
  apple = "05ac";

  cfg = config.services.usbmuxd;

in

{
  options.services.usbmuxd = {

    enable = lib.mkOption {
      default = false;

      description = ''
        Enable the usbmuxd ("USB multiplexing daemon") service. This daemon is
        in charge of multiplexing connections over USB to an iOS device. This is
        needed for transferring data from and to iOS devices (see ifuse). Also
        this may enable plug-n-play tethering for iPhones.
      '';

      type = lib.types.bool;
    };

    package = lib.mkOption {
      default = pkgs.usbmuxd;
      defaultText = lib.literalExpression "pkgs.usbmuxd";
      description = "Which package to use for the usbmuxd daemon.";

      relatedPackages = [
        "usbmuxd"
        "usbmuxd2"
      ];

      type = lib.types.package;
    };

    group = lib.mkOption {
      default = defaultUserGroup;

      description = ''
        The group usbmuxd should use to run after startup.
      '';

      type = lib.types.str;
    };

    user = lib.mkOption {
      default = defaultUserGroup;

      description = ''
        The user usbmuxd should use to run after startup.
      '';

      type = lib.types.str;
    };

  };

  config = lib.mkIf cfg.enable {

    # Give usbmuxd permission for Apple devices
    services.udev.extraRules = ''
      SUBSYSTEM=="usb", ATTR{idVendor}=="${apple}", GROUP="${cfg.group}"
    '';

    systemd.services.usbmuxd = {
      description = "usbmuxd";

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/usbmuxd -U ${cfg.user} -v";
        # Trigger the udev rule manually. This doesn't require replugging the
        # device when first enabling the option to get it to work
        ExecStartPre = "${config.systemd.package}/bin/udevadm trigger -s usb -a idVendor=${apple}";
      };

      unitConfig.Documentation = "man:usbmuxd(8)";
      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.optionalAttrs (cfg.group == defaultUserGroup) {
      ${cfg.group} = { };
    };

    users.users = lib.optionalAttrs (cfg.user == defaultUserGroup) {
      ${cfg.user} = {
        description = "usbmuxd user";
        group = cfg.group;
        isSystemUser = true;
      };
    };

  };
}
