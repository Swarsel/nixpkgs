{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.fritzbox;
  inherit (lib) mkOption types concatStringsSep;
in
{
  extraOpts = {
    gatewayAddress = mkOption {
      default = "fritz.box";

      description = ''
        The hostname or IP of the FRITZ!Box.
      '';

      type = types.str;
    };

    gatewayPort = mkOption {
      default = 49000;

      description = ''
        The port of the FRITZ!Box UPnP service.
      '';

      type = types.port;
    };
  };

  port = 9133;

  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-fritzbox-exporter}/bin/exporter \
          -listen-address ${cfg.listenAddress}:${toString cfg.port} \
          -gateway-address ${cfg.gatewayAddress} \
          -gateway-port ${toString cfg.gatewayPort} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };
  };
}
