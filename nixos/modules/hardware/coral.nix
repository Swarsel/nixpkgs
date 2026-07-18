{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    ;

  cfg = config.hardware.coral;
in

{
  options.hardware.coral = {
    pcie.enable = mkEnableOption "Coral PCIe support";
    usb.enable = mkEnableOption "Coral USB support";
  };

  config = mkMerge [
    (mkIf (cfg.usb.enable || cfg.pcie.enable) {
      users.groups.coral = { };
    })
    (mkIf cfg.usb.enable {
      services.udev.packages = with pkgs; [ libedgetpu ];
    })
    (mkIf cfg.pcie.enable {
      boot.extraModulePackages = with config.boot.kernelPackages; [ gasket ];

      services.udev.extraRules = ''
        SUBSYSTEM=="apex",MODE="0660",GROUP="coral"
      '';
    })
  ];
}
