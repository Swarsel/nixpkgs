{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ebusd;
in
{
  options.services.ebusd = {
    enable = lib.mkEnableOption "ebusd, a daemon for communication with eBUS heating systems";
    package = lib.mkPackageOption pkgs "ebusd" { };

    configpath = lib.mkOption {
      default = "https://ebus.github.io/";

      description = ''
        Directory to read CSV config files from. This can be a local folder or a URL.
      '';

      type = lib.types.str;
    };

    device = lib.mkOption {
      default = "";

      description = ''
        Use DEV as eBUS device [/dev/ttyUSB0].
        This can be either:
          enh:DEVICE or enh:IP:PORT for enhanced device (only adapter v3 and newer),
          ens:DEVICE for enhanced high speed serial device (only adapter v3 and newer with firmware since 20220731),
          DEVICE for serial device (normal speed, for all other serial adapters like adapter v2 as well as adapter v3 in non-enhanced mode), or
          [udp:]IP:PORT for network device.

        Source: <https://github.com/john30/ebusd/wiki/2.-Run#device-options>
      '';

      example = "IP:PORT";
      type = lib.types.str;
    };

    extraArguments = lib.mkOption {
      default = [ ];

      description = ''
        Extra arguments to the ebus daemon
      '';

      type = lib.types.listOf lib.types.str;
    };

    logs =
      let
        # "all" must come first so it can be overridden by more specific areas
        areas = [
          "all"
          "main"
          "network"
          "bus"
          "device"
          "update"
          "other"
        ];
        levels = [
          "none"
          "error"
          "notice"
          "info"
          "debug"
        ];
      in
      lib.listToAttrs (
        map (
          area:
          lib.nameValuePair area (
            lib.mkOption {
              default = "notice";

              description = ''
                Only write log for matching `AREA`s (${lib.concatStringsSep "|" areas}) below or equal to `LEVEL` (${lib.concatStringsSep "|" levels})
              '';

              example = "debug";
              type = lib.types.enum levels;
            }
          )
        ) areas
      );

    mqtt = {
      enable = lib.mkEnableOption "support for MQTT";

      home-assistant = lib.mkOption {
        default = false;

        description = ''
          Adds the Home Assistant topics to MQTT, read more at [MQTT Integration](https://github.com/john30/ebusd/wiki/MQTT-integration)
        '';

        type = lib.types.bool;
      };

      host = lib.mkOption {
        default = "localhost";

        description = ''
          Connect to MQTT broker on HOST.
        '';

        type = lib.types.str;
      };

      password = lib.mkOption {
        description = ''
          The MQTT password.
        '';

        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 1883;

        description = ''
          The port on which to connect to MQTT
        '';

        type = lib.types.port;
      };

      retain = lib.mkEnableOption "set the retain flag on all topics instead of only selected global ones";

      user = lib.mkOption {
        description = ''
          The MQTT user to use
        '';

        type = lib.types.str;
      };
    };

    port = lib.mkOption {
      default = 8888;

      description = ''
        The port on which to listen on
      '';

      type = lib.types.port;
    };

    readonly = lib.mkOption {
      default = false;

      description = ''
        Only read from device, never write to it
      '';

      type = lib.types.bool;
    };

    scanconfig = lib.mkOption {
      default = "full";

      description = ''
        Pick CSV config files matching initial scan ("none" or empty for no initial scan message, "full" for full scan, or a single hex address to scan, default is to send a broadcast ident message).
        If combined with --checkconfig, you can add scan message data as arguments for checking a particular scan configuration, e.g. "FF08070400/0AB5454850303003277201". For further details on this option,
        see [Automatic configuration](https://github.com/john30/ebusd/wiki/4.7.-Automatic-configuration).
      '';

      type = lib.types.str;
    };
  };

  config =
    let
      usesDev = lib.any (prefix: lib.hasPrefix prefix cfg.device) [
        "/"
        "ens:/"
        "enh:/"
      ];
    in
    lib.mkIf cfg.enable {
      systemd.services.ebusd = {
        after = [ "network.target" ];
        description = "EBUSd Service";

        serviceConfig = {
          # Hardening
          CapabilityBoundingSet = "";

          DeviceAllow = lib.optionals usesDev [
            (lib.removePrefix "ens:" (lib.removePrefix "enh:" cfg.device))
          ];

          DevicePolicy = "closed";
          DynamicUser = true;

          ExecStart =
            let
              args = lib.cli.toCommandLineShellGNU { } (
                lib.foldr (a: b: a // b) { } [
                  {
                    inherit (cfg)
                      device
                      port
                      configpath
                      scanconfig
                      readonly
                      ;

                    foreground = true;
                    log = lib.mapAttrsToList (name: value: "${name}:${value}") cfg.logs;
                    mqttretain = cfg.mqtt.retain;
                    updatecheck = "off";
                  }
                  (lib.optionalAttrs cfg.mqtt.enable {
                    mqtthost = cfg.mqtt.host;
                    mqttpass = cfg.mqtt.password;
                    mqttport = cfg.mqtt.port;
                    mqttuser = cfg.mqtt.user;
                  })
                  (lib.optionalAttrs cfg.mqtt.home-assistant {
                    mqttint = "${cfg.package}/etc/ebusd/mqtt-hassio.cfg";
                    mqttjson = true;
                  })
                ]
              );
            in
            "${cfg.package}/bin/ebusd ${args} ${lib.escapeShellArgs cfg.extraArguments}";

          LockPersonality = true;
          MemoryDenyWriteExecute = false;
          NoNewPrivileges = true;
          PrivateDevices = !usesDev;
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
          RemoveIPC = true;
          Restart = "on-failure";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SupplementaryGroups = [ "dialout" ];
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service @pkey"
            "~@privileged @resources"
          ];

          UMask = "0077";
        };

        wantedBy = [ "multi-user.target" ];
      };
    };

  meta.maintainers = with lib.maintainers; [ nathan-gs ];
}
