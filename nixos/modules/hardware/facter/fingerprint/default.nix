# To update devices.json, run:
#   $(nix-build nixos/modules/hardware/facter/fingerprint/update.nix)/bin/update-fprint-devices
{ config, lib, ... }:
let
  facterLib = import ../lib.nix lib;

  devices = builtins.fromJSON (builtins.readFile ./devices.json);
  default = {
    value = 0;
  };

  isSupported = lib.any (
    {
      bus_type ? {
        name = "";
      },
      device ? default,
      vendor ? default,
      ...
    }:
    bus_type.name == "USB"
    && devices ? "${facterLib.toZeroPaddedHex vendor.value}:${facterLib.toZeroPaddedHex device.value}"
  );
in
{
  options.hardware.facter.detected.fingerprint.enable = lib.mkEnableOption "Fingerprint devices" // {
    default =
      isSupported (config.hardware.facter.report.hardware.unknown or [ ])
      || isSupported (config.hardware.facter.report.hardware.fingerprint or [ ])
      || isSupported (config.hardware.facter.report.hardware.usb or [ ]);

    defaultText = "hardware dependent";
  };

  config.services.fprintd.enable = lib.mkIf config.hardware.facter.detected.fingerprint.enable (
    lib.mkDefault true
  );
}
