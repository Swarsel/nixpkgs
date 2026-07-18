{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  inherit (lib)
    getExe
    mkOption
    types
    ;

  inherit (utils) escapeSystemdExecArgs;

  cfg = config.services.prometheus.exporters.rasdaemon;
in
{
  extraOpts = with types; {
    databasePath = mkOption {
      default = "/var/lib/rasdaemon/ras-mc_event.db";

      description = ''
        Path to the RAS daemon machine check event database.
      '';

      type = path;
    };

    enabledCollectors = mkOption {
      default = [
        "aer"
        "mce"
        "mc"
      ];

      description = ''
        List of error types to collect from the event database.
      '';

      type = listOf (enum [
        "aer"
        "mce"
        "mc"
        "extlog"
        "devlink"
        "disk"
      ]);
    };
  };

  port = 10029;

  serviceOpts = {
    serviceConfig = {
      ExecStart = escapeSystemdExecArgs (
        [
          (getExe pkgs.prometheus-rasdaemon-exporter)
          "--address"
          cfg.listenAddress
          "--port"
          (toString cfg.port)
          "--db"
          cfg.databasePath
        ]
        ++ map (collector: "--collector-${collector}") cfg.enabledCollectors
        ++ cfg.extraFlags
      );
    };
  };
}
