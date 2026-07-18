{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.trickster;
in
{
  imports = [
    (mkRenamedOptionModule [ "services" "trickster" "origin" ] [ "services" "trickster" "origin-url" ])
  ];

  options = {
    services.trickster = {
      enable = mkOption {
        default = false;

        description = ''
          Enable Trickster.
        '';

        type = types.bool;
      };

      package = mkPackageOption pkgs "trickster" { };

      configFile = mkOption {
        default = null;

        description = ''
          Path to configuration file.
        '';

        type = types.nullOr types.path;
      };

      instance-id = mkOption {
        default = null;

        description = ''
          Instance ID for when running multiple processes (default null).
        '';

        type = types.nullOr types.int;
      };

      log-level = mkOption {
        default = "info";

        description = ''
          Level of Logging to use (debug, info, warn, error) (default "info").
        '';

        type = types.str;
      };

      metrics-port = mkOption {
        default = 8082;

        description = ''
          Port that the /metrics endpoint will listen on.
        '';

        type = types.port;
      };

      origin-type = mkOption {
        default = "prometheus";

        description = ''
          Type of origin (prometheus, influxdb)
        '';

        type = types.enum [
          "prometheus"
          "influxdb"
        ];
      };

      origin-url = mkOption {
        default = "http://prometheus:9090";

        description = ''
          URL to the Origin. Enter it like you would in grafana, e.g., http://prometheus:9090 (default http://prometheus:9090).
        '';

        type = types.str;
      };

      profiler-port = mkOption {
        default = null;

        description = ''
          Port that the /debug/pprof endpoint will listen on.
        '';

        type = types.nullOr types.port;
      };

      proxy-port = mkOption {
        default = 9090;

        description = ''
          Port that the Proxy server will listen on.
        '';

        type = types.port;
      };

    };
  };

  config = mkIf cfg.enable {
    systemd.services.trickster = {
      after = [ "network.target" ];
      description = "Reverse proxy cache and time series dashboard accelerator";

      serviceConfig = {
        DynamicUser = true;
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";

        ExecStart = ''
          ${cfg.package}/bin/trickster \
          -log-level ${cfg.log-level} \
          -metrics-port ${toString cfg.metrics-port} \
          -origin-type ${cfg.origin-type} \
          -origin-url ${cfg.origin-url} \
          -proxy-port ${toString cfg.proxy-port} \
          ${optionalString (cfg.configFile != null) "-config ${cfg.configFile}"} \
          ${optionalString (cfg.profiler-port != null) "-profiler-port ${cfg.profiler-port}"} \
          ${optionalString (cfg.instance-id != null) "-instance-id ${cfg.instance-id}"}
        '';

        Restart = "always";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with maintainers; [ _1000101 ];

}
