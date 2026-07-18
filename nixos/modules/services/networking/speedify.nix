{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.speedify;
in
{
  options.services.speedify = {
    enable = lib.mkOption {
      default = false;

      description = ''
        This option enables Speedify daemon.
        This sets {option}`networking.firewall.checkReversePath` to "loose", which might be undesirable for security.
      '';

      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs "speedify" { };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "tun" ];
    networking.firewall.checkReversePath = "loose";

    systemd.services.speedify = {
      after = [
        "network-online.target"
      ]
      ++ lib.optional config.networking.networkmanager.enable "NetworkManager.service";

      description = "Speedify Service";

      path = [
        pkgs.procps
        pkgs.nettools
      ];

      serviceConfig = {
        ExecStart = "${cfg.package}/share/speedify/SpeedifyStartup.sh";
        ExecStop = "${cfg.package}/share/speedify/SpeedifyShutdown.sh";
        Restart = "on-failure";
        RestartSec = 5;
        TimeoutStartSec = 30;
        TimeoutStopSec = 30;
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "network.target"
        "network-online.target"
      ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    zahrun
  ];
}
