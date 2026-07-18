{
  config,
  lib,
  pkgs,
  ...
}:
let
  pcmciautils = pkgs.pcmciautils.overrideAttrs {
    inherit (config.hardware.pcmcia) firmware config;
  };
in

{
  ###### interface
  options = {

    hardware.pcmcia = {
      config = lib.mkOption {
        default = null;

        description = ''
          Path to the configuration file which maps the memory, IRQs
          and ports used by the PCMCIA hardware.
        '';

        type = lib.types.nullOr lib.types.path;
      };

      enable = lib.mkOption {
        default = false;

        description = ''
          Enable this option to support PCMCIA card.
        '';

        type = lib.types.bool;
      };

      firmware = lib.mkOption {
        default = [ ];

        description = ''
          List of firmware used to handle specific PCMCIA card.
        '';

        type = lib.types.listOf lib.types.path;
      };
    };
  };

  ###### implementation

  config = lib.mkIf config.hardware.pcmcia.enable {

    boot.kernelModules = [ "pcmcia" ];
    environment.systemPackages = [ pcmciautils ];
    services.udev.packages = [ pcmciautils ];

  };

}
