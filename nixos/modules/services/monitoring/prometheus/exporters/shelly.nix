{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.shelly;
  inherit (lib) mkOption types;
in
{
  extraOpts = {
    metrics-file = mkOption {
      description = ''
        Path to the JSON file with the metric definitions
      '';

      type = types.path;
    };
  };

  port = 9784;

  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-shelly-exporter}/bin/shelly_exporter \
          -metrics-file ${cfg.metrics-file} \
          -listen-address ${cfg.listenAddress}:${toString cfg.port}
      '';
    };
  };
}
