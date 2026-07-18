{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.prometheus.exporters.speedtest;
  inherit (lib)
    mkOption
    types
    concatStringsSep
    optionalString
    ;
in
{
  extraOpts = {
    serverFallback = mkOption {
      default = false;

      description = ''
        If the configured serverID is unavailable, fall back to the closest available server.
      '';

      type = types.bool;
    };

    serverID = mkOption {
      default = -1;

      description = ''
        Speedtest.net server ID to run tests against.
        -1 picks the closest server to your location.
      '';

      type = types.int;
    };
  };

  port = 9798;

  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-speedtest-exporter}/bin/speedtest_exporter \
          -listen-address ${cfg.listenAddress} \
          -port ${toString cfg.port} \
          -server_id ${toString cfg.serverID} \
          ${optionalString cfg.serverFallback "-server_fallback"} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };
  };
}
