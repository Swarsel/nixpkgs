{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.bcg;
  configFile = (pkgs.formats.yaml { }).generate "bcg.conf.yaml" (
    lib.filterAttrsRecursive (n: v: v != null) {
      inherit (cfg) device name mqtt;
      automatic_remove_kit_from_names = cfg.automaticRemoveKitFromNames;
      automatic_rename_generic_nodes = cfg.automaticRenameGenericNodes;
      automatic_rename_kit_nodes = cfg.automaticRenameKitNodes;
      automatic_rename_nodes = cfg.automaticRenameNodes;
      base_topic_prefix = cfg.baseTopicPrefix;
      qos_node_messages = cfg.qosNodeMessages;
      retain_node_messages = cfg.retainNodeMessages;
    }
  );
in
{
  options = {
    services.bcg = {
      enable = lib.mkEnableOption "BigClown gateway";
      package = lib.mkPackageOption pkgs [ "python3Packages" "bcg" ] { };

      automaticRemoveKitFromNames = lib.mkOption {
        default = true;
        description = "Automatically remove kits.";
        type = lib.types.bool;
      };

      automaticRenameGenericNodes = lib.mkOption {
        default = true;
        description = "Automatically rename generic nodes.";
        type = lib.types.bool;
      };

      automaticRenameKitNodes = lib.mkOption {
        default = true;
        description = "Automatically rename kit's nodes.";
        type = lib.types.bool;
      };

      automaticRenameNodes = lib.mkOption {
        default = true;
        description = "Automatically rename all nodes.";
        type = lib.types.bool;
      };

      baseTopicPrefix = lib.mkOption {
        default = "";
        description = "Topic prefix added to all MQTT messages.";
        type = lib.types.str;
      };

      device = lib.mkOption {
        description = "Device name to configure gateway to use.";
        type = lib.types.str;
      };

      environmentFiles = lib.mkOption {
        default = [ ];

        description = ''
          File to load as environment file. Environment variables from this file
          will be interpolated into the config file using envsubst with this
          syntax: `$ENVIRONMENT` or `''${VARIABLE}`.
          This is useful to avoid putting secrets into the nix store.
        '';

        example = [ "/run/keys/bcg.env" ];
        type = lib.types.listOf lib.types.path;
      };

      mqtt = {
        cafile = lib.mkOption {
          default = null;
          description = "Certificate Authority file for MQTT server access.";
          type = with lib.types; nullOr str;
        };

        certfile = lib.mkOption {
          default = null;
          description = "Certificate file for MQTT server access.";
          type = with lib.types; nullOr str;
        };

        host = lib.mkOption {
          default = "127.0.0.1";
          description = "Host where MQTT server is running.";
          type = lib.types.str;
        };

        keyfile = lib.mkOption {
          default = null;
          description = "Key file for MQTT server access.";
          type = with lib.types; nullOr str;
        };

        password = lib.mkOption {
          default = null;
          description = "MQTT server access password.";
          type = with lib.types; nullOr str;
        };

        port = lib.mkOption {
          default = 1883;
          description = "Port of MQTT server.";
          type = lib.types.port;
        };

        username = lib.mkOption {
          default = null;
          description = "MQTT server access username.";
          type = with lib.types; nullOr str;
        };
      };

      name = lib.mkOption {
        default = null;

        description = ''
          Name for the device.

          Supported variables:
          * `{ip}` IP address
          * `{id}` The ID of the connected usb-dongle or core-module

          `null` can be used for automatic detection from gateway firmware.
        '';

        type = with lib.types; nullOr str;
      };

      qosNodeMessages = lib.mkOption {
        default = 1;
        description = "Set the guarantee of MQTT message delivery.";
        type = lib.types.int;
      };

      rename = lib.mkOption {
        default = { };
        description = "Rename nodes to different name.";
        type = with lib.types; attrsOf str;
      };

      retainNodeMessages = lib.mkOption {
        default = false;
        description = "Specify that node messages should be retaied in MQTT broker.";
        type = lib.types.bool;
      };

      verbose = lib.mkOption {
        default = "WARNING";
        description = "Verbosity level.";

        type = lib.types.enum [
          "CRITICAL"
          "ERROR"
          "WARNING"
          "INFO"
          "DEBUG"
        ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      python3Packages.bcg
      python3Packages.bch
    ];

    systemd.services.bcg =
      let
        envConfig = cfg.environmentFiles != [ ];
        finalConfig = if envConfig then "\${RUNTIME_DIRECTORY}/bcg.config.yaml" else configFile;
      in
      {
        after = [ "network-online.target" ];
        description = "BigClown Gateway";

        preStart = lib.mkIf envConfig ''
          umask 077
          ${pkgs.envsubst}/bin/envsubst -i "${configFile}" -o "${finalConfig}"
        '';

        serviceConfig = {
          EnvironmentFile = cfg.environmentFiles;
          ExecStart = "${cfg.package}/bin/bcg -c ${finalConfig} -v ${cfg.verbose}";
          RuntimeDirectory = "bcg";
        };

        wantedBy = [ "multi-user.target" ];

        wants = [
          "network-online.target"
        ]
        ++ lib.optional config.services.mosquitto.enable "mosquitto.service";
      };
  };
}
