{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.mongodb;
  inherit (lib)
    mkOption
    types
    optionalString
    getExe
    length
    concatStringsSep
    concatMapStringsSep
    escapeShellArgs
    ;
in
{
  extraOpts = {
    collStats = mkOption {
      default = [ ];

      description = ''
        List of comma separared databases.collections to get $collStats
      '';

      example = [
        "db1.coll1"
        "db2"
      ];

      type = types.listOf types.str;
    };

    collectAll = mkOption {
      default = false;

      description = ''
        Enable all collectors. Same as specifying all --collector.<name>
      '';

      type = types.bool;
    };

    collector = mkOption {
      default = [ ];
      description = "Enabled collectors";

      example = [
        "diagnosticdata"
        "replicasetstatus"
        "dbstats"
        "topmetrics"
        "currentopmetrics"
        "indexstats"
        "dbstats"
        "profile"
      ];

      type = types.listOf types.str;
    };

    indexStats = mkOption {
      default = [ ];

      description = ''
        List of comma separared databases.collections to get $indexStats
      '';

      example = [
        "db1.coll1"
        "db2"
      ];

      type = types.listOf types.str;
    };

    telemetryPath = mkOption {
      default = "/metrics";
      description = "Metrics expose path";
      example = "/metrics";
      type = types.str;
    };

    uri = mkOption {
      default = "mongodb://localhost:27017/test";
      description = "MongoDB URI to connect to.";
      example = "mongodb://localhost:27017/test";
      type = types.str;
    };
  };

  port = 9216;

  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${getExe pkgs.prometheus-mongodb-exporter} \
          --mongodb.uri="${cfg.uri}" \
          ${
            if cfg.collectAll then
              "--collect-all"
            else
              concatMapStringsSep " " (x: "--collect.${x}") cfg.collector
          } \
          ${
            optionalString (
              length cfg.collStats > 0
            ) "--mongodb.collstats-colls=${concatStringsSep "," cfg.collStats}"
          } \
          ${
            optionalString (
              length cfg.indexStats > 0
            ) "--mongodb.indexstats-colls=${concatStringsSep "," cfg.indexStats}"
          } \
          --web.listen-address="${cfg.listenAddress}:${toString cfg.port}" \
          --web.telemetry-path="${cfg.telemetryPath}" \
          ${escapeShellArgs cfg.extraFlags}
      '';

      RuntimeDirectory = "prometheus-mongodb-exporter";
    };
  };
}
