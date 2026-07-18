{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.bind;
  inherit (lib) mkOption types concatStringsSep;
in
{
  extraOpts = {
    bindGroups = mkOption {
      default = [
        "server"
        "view"
      ];

      description = ''
        List of statistics to collect. Available: [server, view, tasks]
      '';

      type = types.listOf (
        types.enum [
          "server"
          "view"
          "tasks"
        ]
      );
    };

    bindTimeout = mkOption {
      default = "10s";

      description = ''
        Timeout for trying to get stats from Bind.
      '';

      type = types.str;
    };

    bindURI = mkOption {
      default = "http://localhost:8053/";

      description = ''
        HTTP API address of a BIND server.
      '';

      type = types.str;
    };

    bindVersion = mkOption {
      default = "json";

      description = ''
        BIND statistics version. Defaults to JSON.
      '';

      type = types.enum [
        "json"
        "xml"
        "xml.v3"
        "auto"
      ];
    };
  };

  port = 9119;

  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-bind-exporter}/bin/bind_exporter \
          --web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
          --bind.pid-file /var/run/named/named.pid \
          --bind.timeout ${toString cfg.bindTimeout} \
          --bind.stats-url ${cfg.bindURI} \
          --bind.stats-version ${cfg.bindVersion} \
          --bind.stats-groups ${concatStringsSep "," cfg.bindGroups} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };
  };
}
