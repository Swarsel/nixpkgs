{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.prometheus.sachet;
  configFile = pkgs.writeText "sachet.yml" (builtins.toJSON cfg.configuration);
in
{
  options = {
    services.prometheus.sachet = {
      enable = lib.mkEnableOption "Sachet, an SMS alerting tool for the Prometheus Alertmanager";

      address = lib.mkOption {
        default = "localhost";

        description = ''
          The address Sachet will listen to.
        '';

        type = lib.types.str;
      };

      configuration = lib.mkOption {
        default = null;

        description = ''
          Sachet's configuration as a nix attribute set.
        '';

        example = lib.literalExpression ''
          {
            providers = {
              twilio = {
                # environment variables gets expanded at runtime
                account_sid = "$TWILIO_ACCOUNT";
                auth_token = "$TWILIO_TOKEN";
              };
            };
            templates = [ ./some-template.tmpl ];
            receivers = [{
              name = "pager";
              provider = "twilio";
              to = [ "+33123456789" ];
              text = "{{ template \"message\" . }}";
            }];
          }
        '';

        type = lib.types.nullOr lib.types.attrs;
      };

      port = lib.mkOption {
        default = 9876;

        description = ''
          The port Sachet will listen to.
        '';

        type = lib.types.port;
      };

    };
  };

  config = lib.mkIf cfg.enable {
    assertions = lib.singleton {
      assertion = cfg.configuration != null;
      message = "Cannot enable Sachet without a configuration.";
    };

    systemd.services.sachet = {
      after = [
        "network.target"
        "network-online.target"
      ];

      script = ''
        ${pkgs.envsubst}/bin/envsubst -i "${configFile}" > /tmp/sachet.yaml
        exec ${pkgs.prometheus-sachet}/bin/sachet -config /tmp/sachet.yaml -listen-address ${cfg.address}:${toString cfg.port}
      '';

      serviceConfig = {
        DynamicUser = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        Restart = "always";
        WorkingDirectory = "/tmp/";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
