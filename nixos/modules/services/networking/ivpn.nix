{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ivpn;
in
{
  options.services.ivpn = {
    enable = lib.mkOption {
      default = false;

      description = ''
        This option enables iVPN daemon.
        This sets {option}`networking.firewall.checkReversePath` to "loose", which might be undesirable for security.
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "tun" ];

    environment.systemPackages = with pkgs; [
      ivpn
      ivpn-service
    ];

    networking.firewall.checkReversePath = "loose";
    # iVPN writes to /etc/iproute2/rt_tables
    networking.iproute2.enable = true;

    systemd.services.ivpn-service = {
      after = [
        "network-online.target"
        "NetworkManager.service"
        "systemd-resolved.service"
      ];

      description = "iVPN daemon";

      path = [
        # Needed for mount
        "/run/wrappers"
      ];

      serviceConfig = {
        ExecStart = "${pkgs.ivpn-service}/bin/ivpn-service --logging";
        Restart = "always";
        RestartSec = 1;
      };

      startLimitBurst = 5;
      startLimitIntervalSec = 20;
      wantedBy = [ "multi-user.target" ];

      wants = [
        "network.target"
        "network-online.target"
      ];
    };
  };

  meta.maintainers = [ ];
}
