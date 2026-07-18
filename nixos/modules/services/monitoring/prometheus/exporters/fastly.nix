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
    optionals
    types
    ;

  inherit (utils) escapeSystemdExecArgs;

  cfg = config.services.prometheus.exporters.fastly;
in
{
  extraOpts = with types; {
    configFile = mkOption {
      default = null;

      description = ''
        Path to a fastly-exporter configuration file.
        Example one can be generated with `fastly-exporter --config-file-example`.
      '';

      example = "./fastly-exporter-config.txt";
      type = nullOr path;
    };

    environmentFile = mkOption {
      description = ''
        An environment file containg at least the FASTLY_API_TOKEN= environment
        variable.
      '';

      type = path;
    };
  };

  port = 9118;

  serviceOpts = {
    serviceConfig = {
      EnvironmentFile = cfg.environmentFile;

      ExecStart = escapeSystemdExecArgs (
        [
          (getExe pkgs.prometheus-fastly-exporter)
          "-listen"
          "${cfg.listenAddress}:${toString cfg.port}"
        ]
        ++ optionals (cfg.configFile != null) [
          "--config-file"
          cfg.configFile
        ]
        ++ cfg.extraFlags
      );
    };
  };
}
