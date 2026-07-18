{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.zfs;
  inherit (lib)
    mkOption
    types
    concatStringsSep
    concatMapStringsSep
    ;
in
{
  extraOpts = {
    pools = mkOption {
      default = [ ];

      description = ''
        Name of the pool(s) to collect, repeat for multiple pools (default: all pools).
      '';

      type = with types; nullOr (listOf str);
    };

    telemetryPath = mkOption {
      default = "/metrics";

      description = ''
        Path under which to expose metrics.
      '';

      type = types.str;
    };
  };

  port = 9134;

  serviceOpts = {
    # needs zpool
    path = [ config.boot.zfs.package ];

    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-zfs-exporter}/bin/zfs_exporter \
          --web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
          --web.telemetry-path ${cfg.telemetryPath} \
          ${concatMapStringsSep " " (x: "--pool=${x}") cfg.pools} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';

      PrivateDevices = false;
      ProtectClock = false;
    };
  };
}
