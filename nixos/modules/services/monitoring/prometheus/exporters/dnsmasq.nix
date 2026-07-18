{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.dnsmasq;
  inherit (lib)
    mkOption
    types
    concatStringsSep
    escapeShellArg
    ;
in
{
  extraOpts = {
    dnsmasqListenAddress = mkOption {
      default = "localhost:53";

      description = ''
        Address on which dnsmasq listens.
      '';

      type = types.str;
    };

    leasesPath = mkOption {
      default = "/var/lib/dnsmasq/dnsmasq.leases";

      description = ''
        Path to the `dnsmasq.leases` file.
      '';

      example = "/var/lib/misc/dnsmasq.leases";
      type = types.path;
    };
  };

  port = 9153;

  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-dnsmasq-exporter}/bin/dnsmasq_exporter \
          --listen ${cfg.listenAddress}:${toString cfg.port} \
          --dnsmasq ${cfg.dnsmasqListenAddress} \
          --leases_path ${escapeShellArg cfg.leasesPath} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };
  };
}
