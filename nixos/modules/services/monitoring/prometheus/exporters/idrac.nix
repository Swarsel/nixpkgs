{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.idrac;
  inherit (lib) mkOption types;

  configFile =
    if cfg.configurationPath != null then
      cfg.configurationPath
    else
      pkgs.writeText "idrac.yml" (builtins.toJSON cfg.configuration);
in
{
  extraOpts = {
    configuration = mkOption {
      default = null;

      description = ''
        Configuration for iDRAC exporter, as a nix attribute set.

        Configuration reference: <https://github.com/mrlhansen/idrac_exporter/#configuration>

        Mutually exclusive with `configurationPath` option.
      '';

      example = {
        hosts = {
          default = {
            password = "password";
            username = "username";
          };
        };

        metrics = {
          memory = true;
          power = true;
          sel = true;
          sensors = true;
          storage = true;
          system = true;
        };

        retries = 1;
        timeout = 10;
      };

      type = types.nullOr types.attrs;
    };

    configurationPath = mkOption {
      default = null;

      description = ''
        Path to the service's config file. This path can either be a computed path in /nix/store or a path in the local filesystem.

        The config file should NOT be stored in /nix/store as it will contain passwords and/or keys in plain text.

        Mutually exclusive with `configuration` option.

        Configuration reference: <https://github.com/mrlhansen/idrac_exporter/#configuration>
      '';

      example = "/etc/prometheus-idrac-exporter/idrac.yml";
      type = with types; nullOr path;
    };
  };

  port = 9348;

  serviceOpts = {
    serviceConfig = {
      Environment = [
        "IDRAC_EXPORTER_LISTEN_ADDRESS=${cfg.listenAddress}"
        "IDRAC_EXPORTER_LISTEN_PORT=${toString cfg.port}"
      ];

      ExecStart = "${pkgs.prometheus-idrac-exporter}/bin/idrac_exporter -config %d/configFile";
      LoadCredential = "configFile:${configFile}";
    };
  };
}
