{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.r53-ddns;
  pkg = pkgs.r53-ddns;
in
{
  options = {
    services.r53-ddns = {

      enable = mkEnableOption "r53-ddyns";

      domain = mkOption {
        description = "The name of your domain in Route53";
        type = types.str;
      };

      environmentFile = mkOption {
        description = ''
          File containing the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
          in the format of an EnvironmentFile as described by {manpage}`systemd.exec(5)`
        '';

        type = types.str;
      };

      hostname = mkOption {
        description = ''
          Manually specify the hostname. Otherwise the tool will try to use the name
          returned by the OS (Call to gethostname)
        '';

        type = types.str;
      };

      interval = mkOption {
        default = "15min";
        description = "How often to update the entry";
        type = types.str;
      };

      ttl = mkOption {
        description = "The TTL for the generated record";
        type = types.int;
      };

      zoneID = mkOption {
        description = "The ID of your zone in Route53";
        type = types.str;
      };

    };
  };

  config = mkIf cfg.enable {

    systemd.services.r53-ddns = {
      description = "r53-ddns service";

      serviceConfig = {
        DynamicUser = true;
        EnvironmentFile = "${cfg.environmentFile}";

        ExecStart =
          "${pkg}/bin/r53-ddns -zone-id ${cfg.zoneID} -domain ${cfg.domain}"
          + lib.optionalString (cfg.hostname != null) " -hostname ${cfg.hostname}"
          + lib.optionalString (cfg.ttl != null) " -ttl ${toString cfg.ttl}";
      };
    };

    systemd.timers.r53-ddns = {
      description = "r53-ddns timer";

      timerConfig = {
        OnBootSec = cfg.interval;
        OnUnitActiveSec = cfg.interval;
      };

      wantedBy = [ "timers.target" ];
    };

  };
}
