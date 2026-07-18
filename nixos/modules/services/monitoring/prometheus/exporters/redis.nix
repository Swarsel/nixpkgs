{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.redis;
  inherit (lib) concatStringsSep;
in
{
  port = 9121;

  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-redis-exporter}/bin/redis_exporter \
          -web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';

      RestrictAddressFamilies = [ "AF_UNIX" ];
    };
  };
}
