{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    (lib.mkRenamedOptionModule
      [ "hardware" "usbStorage" "manageStartStop" ]
      [ "hardware" "usbStorage" "manageShutdown" ]
    )
  ];

  options.hardware.usbStorage.manageShutdown = lib.mkOption {
    default = false;

    description = ''
      Enable this option to gracefully spin-down external storage during shutdown.
      If you suspect improper head parking after poweroff, install `smartmontools` and check
      for the `Power-Off_Retract_Count` field for an increment.
    '';

    type = lib.types.bool;
  };

  config = lib.mkIf config.hardware.usbStorage.manageShutdown {
    services.udev.extraRules = ''
      ACTION=="add|change", SUBSYSTEM=="scsi_disk", DRIVERS=="usb-storage|uas", ATTR{manage_shutdown}="1"
    '';
  };
}
