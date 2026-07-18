{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.prometheus.exporters.dnssec;
  configFormat = pkgs.formats.toml { };
  configFile = configFormat.generate "dnssec-checks.toml" cfg.configuration;
in
{
  extraOpts = {
    configuration = lib.mkOption {
      default = null;

      description = ''
        dnssec exporter configuration as nix attribute set.

        See <https://github.com/chrj/prometheus-dnssec-exporter/blob/master/README.md>
        for the description of the configuration file format.
      '';

      example = lib.literalExpression ''
        {
          records = [
            {
              zone = "ietf.org";
              record = "@";
              type = "SOA";
            }
            {
              zone = "verisigninc.com";
              record = "@";
              type = "SOA";
            }
          ];
        }
      '';

      type = lib.types.nullOr lib.types.attrs;
    };

    extraFlags = lib.mkOption {
      default = [ ];

      description = ''
        Extra commandline options when launching Prometheus.
      '';

      type = lib.types.listOf lib.types.str;
    };

    listenAddress = lib.mkOption {
      default = null;

      description = ''
        Listen address as host IP and port definition.
      '';

      example = ":9204";
      type = lib.types.nullOr lib.types.str;
    };

    resolvers = lib.mkOption {
      default = [ ];

      description = ''
        DNSSEC capable resolver to be used for the check.
      '';

      example = [ "0.0.0.0:53" ];
      type = lib.types.listOf lib.types.str;
    };

    timeout = lib.mkOption {
      default = null;

      description = ''
        DNS request timeout duration.
      '';

      example = "10s";
      type = lib.types.nullOr lib.types.str;
    };
  };

  port = 9204;

  serviceOpts = {
    serviceConfig =
      let
        startScript = pkgs.writeShellScriptBin "prometheus-dnssec-exporter-start" "${lib.concatStringsSep
          " "
          (
            [ "${pkgs.prometheus-dnssec-exporter}/bin/prometheus-dnssec-exporter" ]
            ++ lib.optionals (cfg.configuration != null) [ "-config ${configFile}" ]
            ++ lib.optionals (cfg.listenAddress != null) [
              "-listen-address ${lib.escapeShellArg cfg.listenAddress}"
            ]
            ++ lib.optionals (cfg.resolvers != [ ]) [
              "-resolvers ${lib.escapeShellArg (lib.concatStringsSep "," cfg.resolvers)}"
            ]
            ++ lib.optionals (cfg.timeout != null) [ "-timeout ${lib.escapeShellArg cfg.timeout}" ]
            ++ cfg.extraFlags
          )
        }";
      in
      {
        ExecStart = lib.getExe startScript;
      };
  };
}
