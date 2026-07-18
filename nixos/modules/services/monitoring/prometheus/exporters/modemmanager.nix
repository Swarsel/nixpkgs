{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.modemmanager;
  inherit (lib) mkOption types concatStringsSep;
in
{
  extraOpts = {
    refreshRate = mkOption {
      default = "5s";

      description = ''
        How frequently ModemManager will refresh the extended signal quality
        information for each modem. The duration should be specified in seconds
        ("5s"), minutes ("1m"), or hours ("1h").
      '';

      type = types.str;
    };
  };

  port = 9539;

  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-modemmanager-exporter}/bin/modemmanager_exporter \
          -addr ${cfg.listenAddress}:${toString cfg.port} \
          -rate ${cfg.refreshRate} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';

      RestrictAddressFamilies = [
        # Need AF_UNIX to collect data
        "AF_UNIX"
      ];

      # Required in order to authenticate with ModemManager via D-Bus.
      SupplementaryGroups = "networkmanager";
    };
  };
}
