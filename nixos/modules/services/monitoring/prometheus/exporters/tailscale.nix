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
    mkPackageOption
    types
    ;

  inherit (utils) escapeSystemdExecArgs;

  cfg = config.services.prometheus.exporters.tailscale;
in
{
  extraOpts = with types; {
    package = mkPackageOption pkgs "prometheus-tailscale-exporter" { };

    environmentFile = mkOption {
      description = ''
        Environment file containg at least the TAILSCALE_TAILNET,
        TAILSCALE_OAUTH_CLIENT_ID, and TAILSCALE_OAUTH_CLIENT_SECRET
        environment variables.
      '';

      type = path;
    };
  };

  port = 9250;

  serviceOpts = {
    serviceConfig = {
      EnvironmentFile = cfg.environmentFile;

      ExecStart = escapeSystemdExecArgs (
        [
          (getExe cfg.package)
          "--listen-address"
          "${cfg.listenAddress}:${toString cfg.port}"
        ]
        ++ cfg.extraFlags
      );
    };
  };
}
