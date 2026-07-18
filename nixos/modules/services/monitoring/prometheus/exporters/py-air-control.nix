{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.py-air-control;
  inherit (lib) mkOption types;

  workingDir = "/var/lib/${cfg.stateDir}";

in
{
  extraOpts = {
    deviceHostname = mkOption {
      description = ''
        The hostname of the air purification device from which to scrape the metrics.
      '';

      example = "192.168.1.123";
      type = types.str;
    };

    protocol = mkOption {
      default = "http";

      description = ''
        The protocol to use when communicating with the air purification device.
        Available: [http, coap, plain_coap]
      '';

      type = types.str;
    };

    stateDir = mkOption {
      default = "prometheus-py-air-control-exporter";

      description = ''
        Directory below `/var/lib` to store runtime data.
        This directory will be created automatically using systemd's StateDirectory mechanism.
      '';

      type = types.str;
    };
  };

  port = 9896;

  serviceOpts = {
    serviceConfig = {
      DynamicUser = false;
      Environment = [ "HOME=${workingDir}" ];

      ExecStart = ''
        ${pkgs.python3Packages.py-air-control-exporter}/bin/py-air-control-exporter \
          --host ${cfg.deviceHostname} \
          --protocol ${cfg.protocol} \
          --listen-port ${toString cfg.port} \
          --listen-address ${cfg.listenAddress}
      '';

      StateDirectory = cfg.stateDir;
      WorkingDirectory = workingDir;
    };
  };
}
