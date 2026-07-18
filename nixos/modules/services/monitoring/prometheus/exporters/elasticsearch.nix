{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  inherit (lib)
    mkIf
    mkOption
    types
    ;

  inherit (utils) escapeSystemdExecArgs;

  cfg = config.services.prometheus.exporters.elasticsearch;
in
{
  extraOpts = {
    package = lib.mkPackageOption pkgs "prometheus-elasticsearch-exporter" { };

    environmentFile = mkOption {
      default = null;

      description = ''
        Path to an environment file, as defined in {manpage}`systemd.exec(5)`,
        used to pass credentials to the exporter without exposing them in the
        process arguments. It should contain either `ES_USERNAME` and
        `ES_PASSWORD`, or `ES_API_KEY`.
      '';

      example = "/run/secrets/elasticsearch-exporter.env";
      type = types.nullOr types.path;
    };

    url = mkOption {
      default = "http://localhost:9200";

      description = ''
        URI of the Elasticsearch (or OpenSearch) node to scrape, passed as
        `--es.uri`. Any credentials embedded here are overridden by the
        `ES_USERNAME`/`ES_PASSWORD` or `ES_API_KEY` environment variables when
        {option}`environmentFile` is set.
      '';

      example = "https://localhost:9200";
      type = types.str;
    };
  };

  port = 9114;

  serviceOpts = {
    serviceConfig = {
      EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;

      ExecStart = escapeSystemdExecArgs (
        [
          (lib.getExe cfg.package)
          "--web.listen-address=${cfg.listenAddress}:${toString cfg.port}"
          "--es.uri=${cfg.url}"
        ]
        ++ cfg.extraFlags
      );
    };
  };
}
