{
  config,
  lib,
  pkgs,
  options,
  utils,
}:

let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;
  cfg = config.services.prometheus.exporters.mqtt;
  toConfigBoolean = x: if x then "True" else "False";
  toConfigList = builtins.concatStringsSep ",";
in
{
  extraOpts = {
    environmentFile = mkOption {
      default = null;

      description = ''
        File to load as environment file. Useful for e.g. setting `MQTT_PASSWORD`
        without putting any secrets into the Nix store.
      '';

      example = [ "/run/secrets/mqtt-exporter" ];
      type = types.nullOr types.path;
    };

    esphomeTopicPrefixes = mkOption {
      default = [ ];
      description = "MQTT topic used for ESPHome messages.";
      type = types.listOf types.str;
    };

    hubitatTopicPrefixes = mkOption {
      default = [ "hubitat/" ];
      description = "MQTT topic used for Hubitat messages.";
      type = types.listOf types.str;
    };

    keepFullTopic = mkEnableOption "Keep entire topic instead of the first two elements only. Usecase: Shelly 3EM";

    logLevel = mkOption {
      default = "INFO";
      description = "Logging level";
      example = "DEBUG";

      type = types.enum [
        "CRITICAL"
        "ERROR"
        "WARNING"
        "INFO"
        "DEBUG"
      ];
    };

    logMqttMessage = mkEnableOption "Log MQTT original message, only if `LOG_LEVEL` is set to DEBUG.";

    mqttAddress = mkOption {
      default = "127.0.0.1";
      description = "IP or hostname of MQTT broker.";
      type = types.str;
    };

    mqttClientId = mkOption {
      default = null;
      description = "Set client ID manually for MQTT connection";
      type = types.nullOr types.str;
    };

    mqttExposeClientId = mkEnableOption "Expose the client ID as a label in Prometheus metrics.";

    mqttIgnoredTopics = mkOption {
      default = [ ];
      description = "Lists of topics to ignore. Accepts wildcards.";
      type = types.listOf types.str;
    };

    mqttKeepAlive = mkOption {
      default = 60;
      description = "Keep alive interval to maintain connection with MQTT broker.";
      example = 30;
      type = types.int;
    };

    mqttPort = mkOption {
      default = 1883;
      description = "TCP port of MQTT broker.";
      type = types.port;
    };

    mqttTopic = mkOption {
      default = "#";
      description = "Topic path to subscribe to.";
      type = types.str;
    };

    mqttUsername = mkOption {
      default = null;
      description = "Username which should be used to authenticate against the MQTT broker.";
      example = "mqttexporter";
      type = types.nullOr types.str;
    };

    mqttV5Protocol = mkEnableOption "Force to use MQTT protocol v5 instead of 3.1.1.";

    prometheusPrefix = mkOption {
      default = "mqtt_";
      description = "Prefix added to the metric name.";
      type = types.str;
    };

    topicLabel = mkOption {
      default = "topic";
      description = "Define the Prometheus label for the topic.";
      type = types.str;
    };

    zigbee2MqttAvailability = mkEnableOption "Normalize sensor name for device availability metric added by Zigbee2MQTT.";

    zwaveTopicPrefix = mkOption {
      default = "zwave/";
      description = "MQTT topic used for Zwavejs2Mqtt messages.";
      type = types.str;
    };
  };

  # https://github.com/kpetremann/mqtt-exporter/tree/master?tab=readme-ov-file#configuration
  port = 9000;

  serviceOpts = {
    environment = {
      ESPHOME_TOPIC_PREFIXES = toConfigList cfg.esphomeTopicPrefixes;
      HUBITAT_TOPIC_PREFIXES = toConfigList cfg.hubitatTopicPrefixes;
      KEEP_FULL_TOPIC = toConfigBoolean cfg.keepFullTopic;
      LOG_LEVEL = cfg.logLevel;
      LOG_MQTT_MESSAGE = toConfigBoolean cfg.logMqttMessage;
      MQTT_ADDRESS = cfg.mqttAddress;
      MQTT_CLIENT_ID = mkIf (cfg.mqttClientId != null) cfg.mqttClientId;
      MQTT_IGNORED_TOPICS = toConfigList cfg.mqttIgnoredTopics;
      MQTT_KEEPALIVE = toString cfg.mqttKeepAlive;
      MQTT_PORT = toString cfg.mqttPort;
      MQTT_TOPIC = cfg.mqttTopic;
      MQTT_USERNAME = cfg.mqttUsername;
      MQTT_V5_PROTOCOL = toConfigBoolean cfg.mqttV5Protocol;
      PROMETHEUS_ADDRESS = cfg.listenAddress;
      PROMETHEUS_PORT = toString cfg.port;
      PROMETHEUS_PREFIX = cfg.prometheusPrefix;
      TOPIC_LABEL = cfg.topicLabel;
      ZIGBEE2MQTT_AVAILABILITY = toConfigBoolean cfg.zigbee2MqttAvailability;
      ZWAVE_TOPIC_PREFIX = cfg.zwaveTopicPrefix;
    };

    serviceConfig = {
      EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;
      ExecStart = lib.getExe pkgs.mqtt-exporter;
    };
  };
}
