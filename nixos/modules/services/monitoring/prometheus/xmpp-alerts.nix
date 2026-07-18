{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.prometheus.xmpp-alerts;
  settingsFormat = pkgs.formats.yaml { };
  configFile = settingsFormat.generate "prometheus-xmpp-alerts.yml" cfg.settings;
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "prometheus" "xmpp-alerts" "configuration" ]
      [ "services" "prometheus" "xmpp-alerts" "settings" ]
    )
  ];

  options.services.prometheus.xmpp-alerts = {
    enable = lib.mkEnableOption "XMPP Web hook service for Alertmanager";

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration for prometheus xmpp-alerts, see
        <https://github.com/jelmer/prometheus-xmpp-alerts/blob/master/xmpp-alerts.yml.example>
        for supported values.
      '';

      type = settingsFormat.type;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.prometheus-xmpp-alerts = {
      after = [ "network-online.target" ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkgs.prometheus-xmpp-alerts}/bin/prometheus-xmpp-alerts --config ${configFile}";
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" ];
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };
}
