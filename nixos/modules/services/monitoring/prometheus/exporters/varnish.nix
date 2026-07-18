{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.varnish;
  inherit (lib)
    mkOption
    types
    mkDefault
    optional
    escapeShellArg
    concatStringsSep
    ;
in
{
  extraOpts = {
    healthPath = mkOption {
      default = null;

      description = ''
        Path under which to expose healthcheck. Disabled unless configured.
      '';

      type = types.nullOr types.str;
    };

    instance = mkOption {
      default = config.services.varnish.stateDir;
      defaultText = lib.literalExpression "config.services.varnish.stateDir";

      description = ''
        varnishstat -n value.
      '';

      type = types.nullOr types.str;
    };

    noExit = mkOption {
      default = false;

      description = ''
        Do not exit server on Varnish scrape errors.
      '';

      type = types.bool;
    };

    raw = mkOption {
      default = false;

      description = ''
        Enable raw stdout logging without timestamps.
      '';

      type = types.bool;
    };

    telemetryPath = mkOption {
      default = "/metrics";

      description = ''
        Path under which to expose metrics.
      '';

      type = types.str;
    };

    varnishStatPath = mkOption {
      default = "varnishstat";

      description = ''
        Path to varnishstat.
      '';

      type = types.str;
    };

    verbose = mkOption {
      default = false;

      description = ''
        Enable verbose logging.
      '';

      type = types.bool;
    };

    withGoMetrics = mkOption {
      default = false;

      description = ''
        Export go runtime and http handler metrics.
      '';

      type = types.bool;
    };
  };

  port = 9131;

  serviceOpts = {
    path = [ config.services.varnish.package ];

    serviceConfig = {
      DynamicUser = false;

      ExecStart = ''
        ${pkgs.prometheus-varnish-exporter}/bin/prometheus_varnish_exporter \
          --web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
          --web.telemetry-path ${cfg.telemetryPath} \
          --varnishstat-path ${escapeShellArg cfg.varnishStatPath} \
          ${concatStringsSep " \\\n  " (
            cfg.extraFlags
            ++ optional (cfg.healthPath != null) "--web.health-path ${cfg.healthPath}"
            ++ optional (cfg.instance != null) "-n ${escapeShellArg cfg.instance}"
            ++ optional cfg.noExit "--no-exit"
            ++ optional cfg.withGoMetrics "--with-go-metrics"
            ++ optional cfg.verbose "--verbose"
            ++ optional cfg.raw "--raw"
          )}
      '';

      RestartSec = mkDefault 1;
    };
  };
}
