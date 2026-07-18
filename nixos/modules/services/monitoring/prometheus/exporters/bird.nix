{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.bird;
  inherit (lib)
    mkOption
    types
    concatStringsSep
    ;
in
{
  extraOpts = {
    birdSocket = mkOption {
      default = "/run/bird/bird.ctl";

      description = ''
        Path to BIRD2 (or BIRD1 v4) socket.
      '';

      type = types.path;
    };

    birdVersion = mkOption {
      default = 2;

      description = ''
        Specifies whether BIRD1 or BIRD2 is in use.
      '';

      type = types.enum [
        1
        2
      ];
    };

    newMetricFormat = mkOption {
      default = true;

      description = ''
        Enable the new more-generic metric format.
      '';

      type = types.bool;
    };
  };

  port = 9324;

  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-bird-exporter}/bin/bird_exporter \
          -web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
          -bird.socket ${cfg.birdSocket} \
          -bird.v2=${if cfg.birdVersion == 2 then "true" else "false"} \
          -format.new=${if cfg.newMetricFormat then "true" else "false"} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';

      RestrictAddressFamilies = [
        # Need AF_UNIX to collect data
        "AF_UNIX"
      ];

      SupplementaryGroups = "bird";
    };
  };
}
