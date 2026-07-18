{
  config,
  lib,
  pkgs,
  options,
  type,
  ...
}:

let
  cfg = config.services.prometheus.exporters."exportarr-${type}";
  exportarrEnvironment = (lib.mapAttrs (_: toString) cfg.environment) // {
    API_KEY_FILE = lib.mkIf (cfg.apiKeyFile != null) "%d/api-key";
    PORT = toString cfg.port;
    URL = cfg.url;
  };
in
{
  extraOpts = {
    package = lib.mkPackageOption pkgs "exportarr" { };

    apiKeyFile = lib.mkOption {
      default = null;

      description = ''
        File containing the api-key.
      '';

      type = lib.types.nullOr lib.types.path;
    };

    environment = lib.mkOption {
      default = { };

      description = ''
        See [the configuration guide](https://github.com/onedr0p/exportarr#configuration) for available options.
      '';

      example = {
        PROWLARR__BACKFILL = true;
      };

      type = lib.types.attrsOf lib.types.str;
    };

    url = lib.mkOption {
      default = "http://127.0.0.1";

      description = ''
        The full URL to Sonarr, Radarr, or Lidarr.
      '';

      type = lib.types.str;
    };
  };

  port = 9708;

  serviceOpts = {
    environment = exportarrEnvironment;

    serviceConfig = {
      ExecStart = ''${cfg.package}/bin/exportarr ${type} "$@"'';
      LoadCredential = lib.optionalString (cfg.apiKeyFile != null) "api-key:${cfg.apiKeyFile}";
      ProcSubset = "pid";
      ProtectProc = "invisible";

      SystemCallFilter = [
        "@system-service"
        "~@privileged"
      ];
    };
  };
}
