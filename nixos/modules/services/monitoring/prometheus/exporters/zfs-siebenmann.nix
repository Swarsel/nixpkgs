{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.zfs-siebenmann;
  inherit (lib)
    mkOption
    types
    concatStringsSep
    optionalString
    ;
in
{
  extraOpts = {
    depth = mkOption {
      default = 1;

      description = ''
        Depth of the vdev tree to report on.
        0 is the pool, 1 is top level vdevs, 2 is devices too.
      '';

      type = types.int;
    };

    fullPath = mkOption {
      default = false;

      description = ''
        Report the full path of disks.
      '';

      type = types.bool;
    };

    pools = mkOption {
      default = [ ];

      description = ''
        Name of the pool(s) to collect, repeat for multiple pools (default: all pools).
      '';

      type = with types; listOf str;
    };
  };

  port = 9700;

  serviceOpts = {
    # needs zpool
    path = [ config.boot.zfs.package ];

    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-siebenmann-zfs-exporter}/bin/zfs_exporter \
          --listen-addr ${cfg.listenAddress}:${toString cfg.port} \
          --depth ${toString cfg.depth} \
          ${optionalString cfg.fullPath "--fullpath"} \
          ${concatStringsSep " " (map (p: "--pool=${p}") cfg.pools)} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';

      PrivateDevices = false;
      ProtectClock = false;
    };
  };
}
