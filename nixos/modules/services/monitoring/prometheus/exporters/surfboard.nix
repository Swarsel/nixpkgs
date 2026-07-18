{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.surfboard;
  inherit (lib) mkOption types concatStringsSep;
in
{
  extraOpts = {
    modemAddress = mkOption {
      default = "192.168.100.1";

      description = ''
        The hostname or IP of the cable modem.
      '';

      type = types.str;
    };
  };

  port = 9239;

  serviceOpts = {
    description = "Prometheus exporter for surfboard cable modem";

    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-surfboard-exporter}/bin/surfboard_exporter \
          --web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
          --modem-address ${cfg.modemAddress} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };

    unitConfig.Documentation = "https://github.com/ipstatic/surfboard_exporter";
  };
}
