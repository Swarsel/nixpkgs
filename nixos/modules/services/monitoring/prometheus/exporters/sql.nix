{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.prometheus.exporters.sql;
  inherit (lib)
    mkOption
    types
    mapAttrs
    mapAttrsToList
    concatStringsSep
    ;
  cfgOptions = {
    options = with types; {
      jobs = mkOption {
        default = { };
        description = "An attrset of metrics scraping jobs to run.";
        type = attrsOf (submodule jobOptions);
      };
    };
  };
  jobOptions = {
    options = with types; {
      connections = mkOption {
        description = "A list of connection strings of the SQL servers to scrape metrics from";
        type = listOf str;
      };

      interval = mkOption {
        description = ''
          How often to run this job, specified in
          [Go duration](https://golang.org/pkg/time/#ParseDuration) format.
        '';

        type = str;
      };

      queries = mkOption {
        description = "SQL queries to run.";
        type = attrsOf (submodule queryOptions);
      };

      startupSql = mkOption {
        default = [ ];
        description = "A list of SQL statements to execute once after making a connection.";
        type = listOf str;
      };
    };
  };
  queryOptions = {
    options = with types; {
      help = mkOption {
        default = null;
        description = "A human-readable description of this metric.";
        type = nullOr str;
      };

      labels = mkOption {
        default = [ ];
        description = "A set of columns that will be used as Prometheus labels.";
        type = listOf str;
      };

      query = mkOption {
        description = "The SQL query to run.";
        type = str;
      };

      values = mkOption {
        description = "A set of columns that will be used as values of this metric.";
        type = listOf str;
      };
    };
  };

  configFile =
    if cfg.configFile != null then
      cfg.configFile
    else
      let
        nameInline = mapAttrsToList (k: v: v // { name = k; });
        renameStartupSql = j: removeAttrs (j // { startup_sql = j.startupSql; }) [ "startupSql" ];
        configuration = {
          jobs = map renameStartupSql (
            nameInline (mapAttrs (k: v: (v // { queries = nameInline v.queries; })) cfg.configuration.jobs)
          );
        };
      in
      builtins.toFile "config.yaml" (builtins.toJSON configuration);
in
{
  extraOpts = {
    configFile = mkOption {
      default = null;

      description = ''
        Path to configuration file.
      '';

      type = with types; nullOr path;
    };

    configuration = mkOption {
      default = null;

      description = ''
        Exporter configuration as nix attribute set. Mutually exclusive with 'configFile' option.
      '';

      type = with types; nullOr (submodule cfgOptions);
    };
  };

  port = 9237;

  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-sql-exporter}/bin/sql_exporter \
          -web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
          -config.file ${configFile} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';

      RestrictAddressFamilies = [
        # Need AF_UNIX to collect data
        "AF_UNIX"
      ];
    };
  };
}
