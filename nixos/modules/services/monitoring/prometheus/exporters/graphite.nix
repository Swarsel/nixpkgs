{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.graphite;
  format = pkgs.formats.yaml { };
in
{
  extraOpts = {
    graphitePort = lib.mkOption {
      default = 9109;

      description = ''
        Port to use for the graphite server.
      '';

      type = lib.types.port;
    };

    mappingSettings = lib.mkOption {
      default = { };

      description = ''
        Mapping configuration for the exporter, see
        <https://github.com/prometheus/graphite_exporter#yaml-config> for
        available options.
      '';

      type = lib.types.submodule {
        options = { };
        freeformType = format.type;
      };
    };
  };

  port = 9108;

  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-graphite-exporter}/bin/graphite_exporter \
          --web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
          --graphite.listen-address ${cfg.listenAddress}:${toString cfg.graphitePort} \
          --graphite.mapping-config ${format.generate "mapping.yml" cfg.mappingSettings} \
          ${lib.concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };
  };
}
