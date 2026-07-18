{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.services.expressvpn.enable = lib.mkOption {
    default = false;

    description = ''
      Enable the ExpressVPN daemon.
    '';

    type = lib.types.bool;
  };

  config = lib.mkIf config.services.expressvpn.enable {
    boot.kernelModules = [ "tun" ];

    systemd.services.expressvpn = {
      after = [
        "network.target"
        "network-online.target"
      ];

      description = "ExpressVPN Daemon";

      serviceConfig = {
        ExecStart = "${pkgs.expressvpn}/bin/expressvpnd";
        Restart = "on-failure";
        RestartSec = 5;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ yureien ];
}
