{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.prometheus.exporters.bitcoin;
  inherit (lib) mkOption types;
in
{
  extraOpts = {
    package = lib.mkPackageOption pkgs "prometheus-bitcoin-exporter" { };

    extraEnv = mkOption {
      default = { };

      description = ''
        Extra environment variables for the exporter.
      '';

      type = types.attrsOf types.str;
    };

    refreshSeconds = mkOption {
      default = 300;

      description = ''
        How often to ask bitcoind for metrics.
      '';

      type = types.ints.unsigned;
    };

    rpcHost = mkOption {
      default = "localhost";

      description = ''
        RPC host.
      '';

      type = types.str;
    };

    rpcPasswordFile = mkOption {
      description = ''
        File containing RPC password.
      '';

      type = types.path;
    };

    rpcPort = mkOption {
      default = 8332;

      description = ''
        RPC port number.
      '';

      type = types.port;
    };

    rpcScheme = mkOption {
      default = "http";

      description = ''
        Whether to connect to bitcoind over http or https.
      '';

      type = types.enum [
        "http"
        "https"
      ];
    };

    rpcUser = mkOption {
      default = "bitcoinrpc";

      description = ''
        RPC user name.
      '';

      type = types.str;
    };
  };

  port = 9332;

  serviceOpts = {
    environment = {
      BITCOIN_RPC_HOST = cfg.rpcHost;
      BITCOIN_RPC_PORT = toString cfg.rpcPort;
      BITCOIN_RPC_SCHEME = cfg.rpcScheme;
      BITCOIN_RPC_USER = cfg.rpcUser;
      METRICS_ADDR = cfg.listenAddress;
      METRICS_PORT = toString cfg.port;
      REFRESH_SECONDS = toString cfg.refreshSeconds;
    }
    // cfg.extraEnv;

    script = ''
      BITCOIN_RPC_PASSWORD=$(cat ${cfg.rpcPasswordFile})
      export BITCOIN_RPC_PASSWORD
      exec ${cfg.package}/bin/bitcoind-monitor.py
    '';
  };
}
