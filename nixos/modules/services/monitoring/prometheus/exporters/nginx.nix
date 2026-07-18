{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.nginx;
  inherit (lib)
    mkOption
    types
    mkMerge
    mkRemovedOptionModule
    mkRenamedOptionModule
    mkIf
    concatStringsSep
    ;
in
{
  imports = [
    (mkRenamedOptionModule [ "telemetryEndpoint" ] [ "telemetryPath" ])
    (mkRemovedOptionModule [ "insecure" ] ''
      This option was replaced by 'prometheus.exporters.nginx.sslVerify'.
    '')
    {
      options.assertions = options.assertions;
      options.warnings = options.warnings;
    }
  ];

  extraOpts = {
    constLabels = mkOption {
      default = [ ];

      description = ''
        A list of constant labels that will be used in every metric.
      '';

      example = [
        "label1=value1"
        "label2=value2"
      ];

      type = types.listOf types.str;
    };

    scrapeUri = mkOption {
      default = "http://localhost/nginx_status";

      description = ''
        Address to access the nginx status page.
        Can be enabled with services.nginx.statusPage = true.
      '';

      type = types.str;
    };

    sslVerify = mkOption {
      default = true;

      description = ''
        Whether to perform certificate verification for https.
      '';

      type = types.bool;
    };

    telemetryPath = mkOption {
      default = "/metrics";

      description = ''
        Path under which to expose metrics.
      '';

      type = types.str;
    };
  };

  port = 9113;

  serviceOpts = mkMerge (
    [
      {
        environment.CONST_LABELS = concatStringsSep "," cfg.constLabels;

        serviceConfig = {
          ExecStart = ''
            ${pkgs.prometheus-nginx-exporter}/bin/nginx-prometheus-exporter \
              --nginx.scrape-uri='${cfg.scrapeUri}' \
              --${lib.optionalString (!cfg.sslVerify) "no-"}nginx.ssl-verify \
              --web.listen-address=${cfg.listenAddress}:${toString cfg.port} \
              --web.telemetry-path=${cfg.telemetryPath} \
              ${concatStringsSep " \\\n  " cfg.extraFlags}
          '';
        };
      }
    ]
    ++ [
      (mkIf config.services.nginx.enable {
        after = [ "nginx.service" ];
        requires = [ "nginx.service" ];
      })
    ]
  );
}
