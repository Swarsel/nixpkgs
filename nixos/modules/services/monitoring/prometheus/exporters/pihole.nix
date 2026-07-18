{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.pihole;
  inherit (lib)
    mkOption
    types
    mkRemovedOptionModule
    optionalString
    ;
in
{
  imports = [
    (mkRemovedOptionModule [ "interval" ] "This option has been removed.")
    {
      options.assertions = options.assertions;
      options.warnings = options.warnings;
    }
  ];

  extraOpts = {
    apiToken = mkOption {
      default = "";

      description = ''
        Pi-Hole API token which can be used instead of a password
      '';

      example = "580a770cb40511eb85290242ac130003580a770cb40511eb85290242ac130003";
      type = types.str;
    };

    password = mkOption {
      default = "";

      description = ''
        The password to login into Pi-Hole. An api token can be used instead.
      '';

      example = "password";
      type = types.str;
    };

    piholeHostname = mkOption {
      default = "pihole";

      description = ''
        Hostname or address where to find the Pi-Hole webinterface
      '';

      example = "127.0.0.1";
      type = types.str;
    };

    piholePort = mkOption {
      default = 80;

      description = ''
        The port Pi-Hole webinterface is reachable on
      '';

      example = 443;
      type = types.port;
    };

    protocol = mkOption {
      default = "http";

      description = ''
        The protocol which is used to connect to Pi-Hole
      '';

      example = "https";

      type = types.enum [
        "http"
        "https"
      ];
    };

    timeout = mkOption {
      default = "5s";

      description = ''
        Controls the timeout to connect to a Pi-Hole instance
      '';

      type = types.str;
    };
  };

  port = 9617;

  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-pihole-exporter}/bin/pihole-exporter \
          ${optionalString (cfg.apiToken != "") "-pihole_api_token ${cfg.apiToken}"} \
          -pihole_hostname ${cfg.piholeHostname} \
          ${optionalString (cfg.password != "") "-pihole_password ${cfg.password}"} \
          -pihole_port ${toString cfg.piholePort} \
          -pihole_protocol ${cfg.protocol} \
          -port ${toString cfg.port} \
          -timeout ${cfg.timeout}
      '';
    };
  };
}
