{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.influxdb;
  inherit (lib) mkOption types concatStringsSep;
in
{
  extraOpts = {
    sampleExpiry = mkOption {
      default = "5m";
      description = "How long a sample is valid for";
      example = "10m";
      type = types.str;
    };

    udpBindAddress = mkOption {
      default = ":9122";
      description = "Address on which to listen for udp packets";
      example = "192.0.2.1:9122";
      type = types.str;
    };
  };

  port = 9122;

  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-influxdb-exporter}/bin/influxdb_exporter \
        --web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
        --influxdb.sample-expiry ${cfg.sampleExpiry} ${concatStringsSep " " cfg.extraFlags}
      '';

      RuntimeDirectory = "prometheus-influxdb-exporter";
    };
  };
}
