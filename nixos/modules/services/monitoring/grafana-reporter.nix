{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.grafana_reporter;

in
{
  options.services.grafana_reporter = {
    enable = lib.mkEnableOption "grafana_reporter";

    addr = lib.mkOption {
      default = "127.0.0.1";
      description = "Listening address.";
      type = lib.types.str;
    };

    grafana = {
      addr = lib.mkOption {
        default = "127.0.0.1";
        description = "Grafana address.";
        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 3000;
        description = "Grafana port.";
        type = lib.types.port;
      };

      protocol = lib.mkOption {
        default = "http";
        description = "Grafana protocol.";

        type = lib.types.enum [
          "http"
          "https"
        ];
      };

    };

    port = lib.mkOption {
      default = 8686;
      description = "Listening port.";
      type = lib.types.port;
    };

    templateDir = lib.mkOption {
      default = pkgs.grafana_reporter;
      defaultText = lib.literalExpression "pkgs.grafana_reporter";
      description = "Optional template directory to use custom tex templates";
      type = lib.types.either lib.types.str lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.grafana_reporter = {
      after = [ "network.target" ];
      description = "Grafana Reporter Service Daemon";

      serviceConfig =
        let
          args = lib.concatStringsSep " " [
            "-proto ${cfg.grafana.protocol}://"
            "-ip ${cfg.grafana.addr}:${toString cfg.grafana.port}"
            "-port :${toString cfg.port}"
            "-templates ${cfg.templateDir}"
          ];
        in
        {
          ExecStart = "${pkgs.grafana-reporter}/bin/grafana-reporter ${args}";
        };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
