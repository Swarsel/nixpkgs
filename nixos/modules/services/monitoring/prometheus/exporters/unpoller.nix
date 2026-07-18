{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.unpoller;
  inherit (lib) mkEnableOption generators;

  configFile = pkgs.writeText "prometheus-unpoller-exporter.json" (
    generators.toJSON { } {
      inherit (cfg) loki;
      datadog.disable = true; # workaround for https://github.com/unpoller/unpoller/issues/442
      influxdb.disable = true;
      poller = { inherit (cfg.log) debug quiet; };

      prometheus = {
        http_listen = "${cfg.listenAddress}:${toString cfg.port}";
        report_errors = cfg.log.prometheusErrors;
      };

      unifi = { inherit (cfg) controllers; };
    }
  );

in
{
  extraOpts = {
    inherit (options.services.unpoller.unifi) controllers;
    inherit (options.services.unpoller) loki;

    log = {
      debug = mkEnableOption "debug logging including line numbers, high resolution timestamps, per-device logs";
      prometheusErrors = mkEnableOption "emitting errors to prometheus";
      quiet = mkEnableOption "startup and error logs only";
    };
  };

  port = 9130;

  serviceOpts.serviceConfig = {
    DynamicUser = false;
    ExecStart = "${pkgs.unpoller}/bin/unpoller --config ${configFile}";
  };
}
