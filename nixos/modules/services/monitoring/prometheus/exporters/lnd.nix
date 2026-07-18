{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.lnd;
  inherit (lib) mkOption types concatStringsSep;
in
{
  extraOpts = {
    lndHost = mkOption {
      default = "localhost:10009";

      description = ''
        lnd instance gRPC address:port.
      '';

      type = types.str;
    };

    lndMacaroonDir = mkOption {
      description = ''
        Path to lnd macaroons.
      '';

      type = types.path;
    };

    lndTlsPath = mkOption {
      description = ''
        Path to lnd TLS certificate.
      '';

      type = types.path;
    };
  };

  port = 9092;

  serviceOpts.serviceConfig = {
    ExecStart = ''
      ${pkgs.prometheus-lnd-exporter}/bin/lndmon \
        --prometheus.listenaddr=${cfg.listenAddress}:${toString cfg.port} \
        --prometheus.logdir=/var/log/prometheus-lnd-exporter \
        --lnd.host=${cfg.lndHost} \
        --lnd.tlspath=${cfg.lndTlsPath} \
        --lnd.macaroondir=${cfg.lndMacaroonDir} \
        ${concatStringsSep " \\\n  " cfg.extraFlags}
    '';

    LogsDirectory = "prometheus-lnd-exporter";

    ReadOnlyPaths = [
      cfg.lndTlsPath
      cfg.lndMacaroonDir
    ];
  };
}
