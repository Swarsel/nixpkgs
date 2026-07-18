{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.junos-czerwonk;
  inherit (lib)
    mkOption
    types
    escapeShellArg
    mkIf
    concatStringsSep
    ;

  configFile =
    if cfg.configuration != null then configurationFile else (escapeShellArg cfg.configurationFile);

  configurationFile = pkgs.writeText "prometheus-junos-czerwonk-exporter.conf" (
    builtins.toJSON (cfg.configuration)
  );
in
{
  extraOpts = {
    configuration = mkOption {
      default = null;

      description = ''
        JunOS exporter configuration as nix attribute set. Mutually exclusive with the `configurationFile` option.
      '';

      example = {
        devices = [
          {
            host = "router1";
            key_file = "/path/to/key";
          }
        ];
      };

      type = types.nullOr types.attrs;
    };

    configurationFile = mkOption {
      default = null;

      description = ''
        Specify the JunOS exporter configuration file to use.
      '';

      type = types.nullOr types.path;
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        File containing env-vars to be substituted into the exporter's config.
      '';

      type = types.nullOr types.str;
    };

    telemetryPath = mkOption {
      default = "/metrics";

      description = ''
        Path under which to expose metrics.
      '';

      type = types.str;
    };
  };

  port = 9326;

  serviceOpts = {
    serviceConfig = {
      DynamicUser = false;
      EnvironmentFile = mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];

      ExecStart = ''
        ${pkgs.prometheus-junos-czerwonk-exporter}/bin/junos_exporter \
          -web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
          -web.telemetry-path ${cfg.telemetryPath} \
          -config.file ''${RUNTIME_DIRECTORY}/junos-exporter.json \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';

      ExecStartPre = [
        "${pkgs.writeShellScript "subst-secrets-junos-czerwonk-exporter" ''
          umask 0077
          ${pkgs.envsubst}/bin/envsubst -i ${configFile} -o ''${RUNTIME_DIRECTORY}/junos-exporter.json
        ''}"
      ];

      RuntimeDirectory = "prometheus-junos-czerwonk-exporter";
    };
  };
}
