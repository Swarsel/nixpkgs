{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.zigbee2mqtt;

  format = pkgs.formats.yaml { };
  configFile = format.generate "zigbee2mqtt.yaml" cfg.settings;

in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "zigbee2mqtt"
      "config"
    ] "The option services.zigbee2mqtt.config was renamed to services.zigbee2mqtt.settings.")
  ];

  options.services.zigbee2mqtt = {
    enable = lib.mkEnableOption "zigbee2mqtt service";
    package = lib.mkPackageOption pkgs "zigbee2mqtt" { };

    dataDir = lib.mkOption {
      default = "/var/lib/zigbee2mqtt";
      description = "Zigbee2mqtt data directory";
      type = lib.types.path;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Your {file}`configuration.yaml` as a Nix attribute set.
        Check the [documentation](https://www.zigbee2mqtt.io/information/configuration.html)
        for possible options.
      '';

      example = lib.literalExpression ''
        {
          homeassistant.enabled = config.services.home-assistant.enable;
          permit_join = true;
          serial = {
            port = "/dev/ttyACM1";
          };
        }
      '';

      type = format.type;
    };
  };

  config = lib.mkIf (cfg.enable) {

    # preset config values
    services.zigbee2mqtt.settings = {
      # reference device/group configuration, that is kept in a separate file
      # to prevent it being overwritten in the units ExecStartPre script
      devices = lib.mkDefault "devices.yaml";
      groups = lib.mkDefault "groups.yaml";
      homeassistant.enabled = lib.mkDefault config.services.home-assistant.enable;

      mqtt = {
        base_topic = lib.mkDefault "zigbee2mqtt";
        server = lib.mkDefault "mqtt://localhost:1883";
      };

      permit_join = lib.mkDefault false;
      serial.port = lib.mkDefault "/dev/ttyACM0";
    };

    systemd.services.zigbee2mqtt = {
      after = [ "network.target" ];
      description = "Zigbee2mqtt Service";
      environment.ZIGBEE2MQTT_DATA = cfg.dataDir;

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = "";

        DeviceAllow = lib.optionals (lib.hasPrefix "/" cfg.settings.serial.port) [
          cfg.settings.serial.port
        ];

        DevicePolicy = "closed";
        ExecStart = "${cfg.package}/bin/zigbee2mqtt";
        ExecStartPre = "${lib.getExe' pkgs.coreutils "cp"} --no-preserve=mode ${configFile} '${cfg.dataDir}/configuration.yaml'";
        Group = "zigbee2mqtt";
        LockPersonality = true;
        MemoryDenyWriteExecute = false;
        NoNewPrivileges = true;
        PrivateDevices = false; # prevents access to /dev/serial, because it is set 0700 root:root
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        ReadWritePaths = cfg.dataDir;
        RemoveIPC = true;
        Restart = "on-failure";
        RestartSec = 10;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "zigbee2mqtt";
        StateDirectoryMode = "0700";

        SupplementaryGroups = [
          "dialout"
        ];

        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service @pkey"
          "~@privileged @resources"
          "@chown"
        ];

        UMask = "0077";
        User = "zigbee2mqtt";
        WorkingDirectory = cfg.dataDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.zigbee2mqtt.gid = config.ids.gids.zigbee2mqtt;

    users.users.zigbee2mqtt = {
      createHome = true;
      group = "zigbee2mqtt";
      home = cfg.dataDir;
      uid = config.ids.uids.zigbee2mqtt;
    };
  };

  meta.maintainers = with lib.maintainers; [ hexa ];
}
