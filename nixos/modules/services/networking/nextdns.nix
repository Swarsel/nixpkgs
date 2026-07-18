{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.nextdns;
in
{
  options = {
    services.nextdns = {
      enable = mkOption {
        default = false;
        description = "Whether to enable the NextDNS DNS/53 to DoH Proxy service.";
        type = types.bool;
      };

      arguments = mkOption {
        default = [ ];
        description = "Additional arguments to be passed to nextdns run.";

        example = [
          "-config"
          "10.0.3.0/24=abcdef"
        ];

        type = types.listOf types.str;
      };
    };
  };

  # https://github.com/nextdns/nextdns/blob/628ea509eaaccd27adb66337db03e5b56f6f38a8/host/service/systemd/service.go
  config = mkIf cfg.enable {
    systemd.services.nextdns = {
      after = [ "network.target" ];
      before = [ "nss-lookup.target" ];
      description = "NextDNS DNS/53 to DoH Proxy";

      environment = {
        SERVICE_RUN_MODE = "1";
      };

      serviceConfig = {
        ExecStart = "${pkgs.nextdns}/bin/nextdns run ${escapeShellArgs config.services.nextdns.arguments}";
        LimitMEMLOCK = "infinity";
        RestartSec = 120;
      };

      startLimitBurst = 10;
      startLimitIntervalSec = 5;
      wantedBy = [ "multi-user.target" ];
      wants = [ "nss-lookup.target" ];
    };
  };
}
