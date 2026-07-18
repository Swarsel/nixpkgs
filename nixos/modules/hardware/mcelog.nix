{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {

    hardware.mcelog = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Enable the Machine Check Exception logger.
        '';

        type = lib.types.bool;
      };
    };

  };

  config = lib.mkIf config.hardware.mcelog.enable {
    systemd = {
      packages = [ pkgs.mcelog ];

      services.mcelog = {
        serviceConfig = {
          PrivateNetwork = true;
          PrivateTmp = true;
          ProtectHome = true;
        };

        wantedBy = [ "multi-user.target" ];
      };
    };
  };
}
