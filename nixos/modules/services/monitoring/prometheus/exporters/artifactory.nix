{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.artifactory;
  inherit (lib) mkOption types concatStringsSep;
in
{
  extraOpts = {
    artiAccessToken = mkOption {
      default = "";

      description = ''
        Access token for authentication against JFrog Artifactory API.
        One of the password or access token needs to be set.
      '';

      type = types.str;
    };

    artiPassword = mkOption {
      default = "";

      description = ''
        Password for authentication against JFrog Artifactory API.
        One of the password or access token needs to be set.
      '';

      type = types.str;
    };

    artiUsername = mkOption {
      description = ''
        Username for authentication against JFrog Artifactory API.
      '';

      type = types.str;
    };

    scrapeUri = mkOption {
      default = "http://localhost:8081/artifactory";

      description = ''
        URI on which to scrape JFrog Artifactory.
      '';

      type = types.str;
    };
  };

  port = 9531;

  serviceOpts = {
    serviceConfig = {
      Environment = [
        "ARTI_USERNAME=${cfg.artiUsername}"
        "ARTI_PASSWORD=${cfg.artiPassword}"
        "ARTI_ACCESS_TOKEN=${cfg.artiAccessToken}"
      ];

      ExecStart = ''
        ${pkgs.prometheus-artifactory-exporter}/bin/artifactory_exporter \
          --web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
          --artifactory.scrape-uri ${cfg.scrapeUri} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };
  };
}
