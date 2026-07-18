{
  config,
  lib,
  pkgs,
  ...
}:
{
  ###### implementation
  imports = [
    (lib.mkRenamedOptionModule [ "hardware" "usbWwan" ] [ "hardware" "usb-modeswitch" ])
  ];

  ###### interface
  options = {

    hardware.usb-modeswitch = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Enable this option to support certain USB WLAN and WWAN adapters.

          These network adapters initial present themselves as Flash Drives containing their drivers.
          This option enables automatic switching to the networking mode.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf config.hardware.usb-modeswitch.enable {
    # The systemd service requires the usb-modeswitch-data. The
    # usb-modeswitch package intends to discover this via the
    # filesystem at /usr/share/usb_modeswitch, and merge it with user
    # configuration in /etc/usb_modeswitch.d. Configuring the correct
    # path in the package is difficult, as it would cause a cyclic
    # dependency.
    environment.etc."usb_modeswitch.d".source = "${pkgs.usb-modeswitch-data}/share/usb_modeswitch";
    # Attaches device specific handlers.
    services.udev.packages = with pkgs; [ usb-modeswitch-data ];
    # Triggered by udev, usb-modeswitch creates systemd services via a
    # template unit in the usb-modeswitch package.
    systemd.packages = with pkgs; [ usb-modeswitch ];
  };
}
