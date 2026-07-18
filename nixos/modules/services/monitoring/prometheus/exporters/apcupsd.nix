{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.apcupsd;
  inherit (lib) mkOption types concatStringsSep;
in
{
  extraOpts = {
    apcupsdAddress = mkOption {
      default = ":3551";

      description = ''
        Address of the apcupsd Network Information Server (NIS).
      '';

      type = types.str;
    };

    apcupsdNetwork = mkOption {
      default = "tcp";

      description = ''
        Network of the apcupsd Network Information Server (NIS): one of "tcp", "tcp4", or "tcp6".
      '';

      type = types.enum [
        "tcp"
        "tcp4"
        "tcp6"
      ];
    };
  };

  port = 9162;

  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-apcupsd-exporter}/bin/apcupsd_exporter \
          -telemetry.addr ${cfg.listenAddress}:${toString cfg.port} \
          -apcupsd.addr ${cfg.apcupsdAddress} \
          -apcupsd.network ${cfg.apcupsdNetwork} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };
  };
}
