{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mqtt2influxdb;
  filterNull = lib.filterAttrsRecursive (n: v: v != null);
  configFile = (pkgs.formats.yaml { }).generate "mqtt2influxdb.config.yaml" (filterNull {
    inherit (cfg) mqtt influxdb;
    points = map filterNull cfg.points;
  });

  pointType = lib.types.submodule {
    options = {
      fields = lib.mkOption {
        description = "Field selector.";

        type = lib.types.submodule {
          options = {
            type = lib.mkOption {
              default = null;
              description = "Type to be picked up";
              type = with lib.types; nullOr str;
            };

            value = lib.mkOption {
              default = "$.payload";
              description = "Value to be picked up";
              type = lib.types.str;
            };
          };
        };
      };

      measurement = lib.mkOption {
        description = "Name of the measurement";
        type = lib.types.str;
      };

      tags = lib.mkOption {
        default = { };
        description = "Tags applied";
        type = with lib.types; attrsOf str;
      };

      topic = lib.mkOption {
        description = "MQTT topic to subscribe to.";
        type = lib.types.str;
      };
    };
  };

  defaultPoints = [
    {
      fields.value = "$.payload";
      measurement = "temperature";

      tags = {
        channel = "$.topic[3]";
        id = "$.topic[1]";
      };

      topic = "node/+/thermometer/+/temperature";
    }
    {
      fields.value = "$.payload";
      measurement = "relative-humidity";

      tags = {
        channel = "$.topic[3]";
        id = "$.topic[1]";
      };

      topic = "node/+/hygrometer/+/relative-humidity";
    }
    {
      fields.value = "$.payload";
      measurement = "illuminance";

      tags = {
        id = "$.topic[1]";
      };

      topic = "node/+/lux-meter/0:0/illuminance";
    }
    {
      fields.value = "$.payload";
      measurement = "pressure";

      tags = {
        id = "$.topic[1]";
      };

      topic = "node/+/barometer/0:0/pressure";
    }
    {
      fields.value = "$.payload";
      measurement = "co2";

      tags = {
        id = "$.topic[1]";
      };

      topic = "node/+/co2-meter/-/concentration";
    }
    {
      fields.value = "$.payload";
      measurement = "voltage";

      tags = {
        id = "$.topic[1]";
      };

      topic = "node/+/battery/+/voltage";
    }
    {
      fields.value = "$.payload";
      measurement = "button";

      tags = {
        channel = "$.topic[3]";
        id = "$.topic[1]";
      };

      topic = "node/+/push-button/+/event-count";
    }
    {
      fields.value = "$.payload";
      measurement = "tvoc";

      tags = {
        id = "$.topic[1]";
      };

      topic = "node/+/voc-lp-sensor/0:0/tvoc";
    }
  ];
in
{
  options = {
    services.mqtt2influxdb = {
      enable = lib.mkEnableOption "BigClown MQTT to InfluxDB bridge";
      package = lib.mkPackageOption pkgs [ "python3Packages" "mqtt2influxdb" ] { };

      environmentFiles = lib.mkOption {
        default = [ ];

        description = ''
          File to load as environment file. Environment variables from this file
          will be interpolated into the config file using envsubst with this
          syntax: `$ENVIRONMENT` or `''${VARIABLE}`.
          This is useful to avoid putting secrets into the nix store.
        '';

        example = [ "/run/keys/mqtt2influxdb.env" ];
        type = lib.types.listOf lib.types.path;
      };

      influxdb = {
        database = lib.mkOption {
          description = "Name of the InfluxDB database.";
          type = lib.types.str;
        };

        host = lib.mkOption {
          default = "127.0.0.1";
          description = "Host where InfluxDB server is running.";
          type = lib.types.str;
        };

        password = lib.mkOption {
          default = null;

          description = ''
            Password for InfluxDB login.

            It is highly suggested to use here replacement through
            environmentFiles as otherwise the password is put world readable to
            the store.
          '';

          type = with lib.types; nullOr str;
        };

        port = lib.mkOption {
          default = 8086;
          description = "InfluxDB server port";
          type = lib.types.port;
        };

        ssl = lib.mkOption {
          default = false;
          description = "Use SSL to connect to the InfluxDB server.";
          type = lib.types.bool;
        };

        username = lib.mkOption {
          default = null;
          description = "Username for InfluxDB login.";
          type = with lib.types; nullOr str;
        };

        verify_ssl = lib.mkOption {
          default = true;
          description = "Verify SSL certificate when connecting to the InfluxDB server.";
          type = lib.types.bool;
        };
      };

      mqtt = {
        cafile = lib.mkOption {
          default = null;
          description = "Certification Authority file for MQTT";
          type = with lib.types; nullOr path;
        };

        certfile = lib.mkOption {
          default = null;
          description = "Certificate file for MQTT";
          type = with lib.types; nullOr path;
        };

        host = lib.mkOption {
          default = "127.0.0.1";
          description = "Host where MQTT server is running.";
          type = lib.types.str;
        };

        keyfile = lib.mkOption {
          default = null;
          description = "Key file for MQTT";
          type = with lib.types; nullOr path;
        };

        password = lib.mkOption {
          default = null;

          description = ''
            MQTT password.

            It is highly suggested to use here replacement through
            environmentFiles as otherwise the password is put world readable to
            the store.
          '';

          type = with lib.types; nullOr str;
        };

        port = lib.mkOption {
          default = 1883;
          description = "MQTT server port.";
          type = lib.types.port;
        };

        username = lib.mkOption {
          default = null;
          description = "Username used to connect to the MQTT server.";
          type = with lib.types; nullOr str;
        };
      };

      points = lib.mkOption {
        default = defaultPoints;
        description = "Points to bridge from MQTT to InfluxDB.";
        type = lib.types.listOf pointType;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.bigclown-mqtt2influxdb =
      let
        envConfig = cfg.environmentFiles != [ ];
        finalConfig = if envConfig then "$RUNTIME_DIRECTORY/mqtt2influxdb.config.yaml" else configFile;
      in
      {
        description = "BigClown MQTT to InfluxDB bridge";

        preStart = ''
          umask 077
          ${pkgs.envsubst}/bin/envsubst -i "${configFile}" -o "${finalConfig}"
        '';

        serviceConfig = {
          EnvironmentFile = cfg.environmentFiles;
          ExecStart = "${lib.getExe cfg.package} -dc ${finalConfig}";
          RuntimeDirectory = "mqtt2influxdb";
        };

        wantedBy = [ "multi-user.target" ];
        wants = lib.mkIf config.services.mosquitto.enable [ "mosquitto.service" ];
      };
  };
}
