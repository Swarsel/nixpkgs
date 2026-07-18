{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.deye-dummycloud;
in
{
  options.services.deye-dummycloud = {
    enable = lib.mkEnableOption "the deye-dummycloud service";

    mqttBrokerUrl = lib.mkOption {
      default = "mqtt://localhost";
      description = "MQTT broker URL";
      type = lib.types.str;
    };

    mqttPassword = lib.mkOption {
      default = "";
      description = "MQTT password";
      type = lib.types.str;
    };

    mqttUsername = lib.mkOption {
      default = "";
      description = "MQTT username";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.deye-dummycloud ];

    systemd.services.deye-dummycloud = {
      after = [ "network.target" ];
      description = "Dummycloud server for DEYE microinverters and bridge to mqtt";

      serviceConfig = {
        DynamicUser = true;

        Environment = [
          "MQTT_BROKER_URL=${cfg.mqttBrokerUrl}"
          "MQTT_USERNAME=${cfg.mqttUsername}"
          "MQTT_PASSWORD=${cfg.mqttPassword}"
        ];

        ExecStart = "${pkgs.lib.getExe pkgs.nodejs-slim} app.js";
        ProtectHome = true;
        ProtectSystem = "full";
        Restart = "always";
        User = "deye-dummycloud";
        WorkingDirectory = "${pkgs.deye-dummycloud}/lib/node_modules/deye-dummycloud";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
    };
  };
}
