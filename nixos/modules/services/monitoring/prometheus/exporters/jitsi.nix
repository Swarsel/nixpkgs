{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.jitsi;
  inherit (lib)
    mkOption
    types
    escapeShellArg
    concatStringsSep
    ;
in
{
  extraOpts = {
    interval = mkOption {
      default = "30s";

      description = ''
        How often to scrape new data
      '';

      example = "1min";
      type = types.str;
    };

    url = mkOption {
      default = "http://localhost:8080/colibri/stats";

      description = ''
        Jitsi Videobridge metrics URL to monitor.
        This is usually /colibri/stats on port 8080 of the jitsi videobridge host.
      '';

      type = types.str;
    };
  };

  port = 9700;

  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-jitsi-exporter}/bin/jitsiexporter \
          -url ${escapeShellArg cfg.url} \
          -host ${cfg.listenAddress} \
          -port ${toString cfg.port} \
          -interval ${toString cfg.interval} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };
  };
}
