{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.meshtasticd;
  format = pkgs.formats.yaml { };
  configFile = format.generate "config.yaml" cfg.settings;
in
{
  options.services.meshtasticd = {
    enable = lib.mkEnableOption "Meshtastic daemon";
    package = lib.mkPackageOption pkgs "meshtasticd" { };

    dataDir = lib.mkOption {
      default = "/var/lib/meshtasticd";

      description = ''
        The data directory.
      '';

      type = lib.types.path;
    };

    group = lib.mkOption {
      default = "meshtasticd";
      description = "Group meshtasticd runs as.";
      type = lib.types.str;
    };

    port = lib.mkOption {
      default = 4403;
      description = "Port to listen on";
      type = lib.types.port;
    };

    settings = lib.mkOption {
      description = ''
        The Meshtastic configuration file.

        An example of configuration can be found at <https://github.com/meshtastic/firmware/blob/develop/bin/config-dist.yaml>
      '';

      example = lib.literalExpression ''
        Lora = {
          Module = "auto";
        };
        Webserver = {
          Port = 9443;
          RootPath = pkgs.meshtastic-web;
        };
        General = {
          MaxNodes = 200;
          MaxMessageQueue = 100;
          MACAddressSource = "eth0";
        };
      '';

      type = format.type;
    };

    user = lib.mkOption {
      default = "meshtasticd";
      description = "User meshtasticd runs as.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    # The `meshtasticd` package provides udev rules.
    services.udev.packages = [
      cfg.package
    ];

    # Creation of the `meshtasticd` service.
    # Based on the official meshtasticd service file: https://github.com/meshtastic/firmware/blob/develop/bin/meshtasticd.service
    systemd.services.meshtasticd = {
      after = [
        "network-online.target"
        "network.target"
      ];

      description = "Meshtastic Native Daemon";

      serviceConfig = {
        AmbientCapabilities = [
          "CAP_NET_BIND_SERVICE"
        ];

        ExecStart = "${lib.getExe cfg.package} --port=${toString cfg.port} --fsdir=${cfg.dataDir} --config=${configFile} --verbose";
        Group = cfg.group;
        Restart = "always";
        RestartSec = "3";
        StateDirectory = "meshtasticd";
        Type = "simple";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "network-online.target"
        "network.target"
      ];
    };

    # Creation of the `meshtasticd` privilege user.
    users = {
      groups = lib.mkIf (cfg.group == "meshtasticd") {
        gpio = { };
        meshtasticd = { };
        # These groups are required for udev rules to work properly.
        spi = { };
      };

      users = lib.mkIf (cfg.user == "meshtasticd") {
        meshtasticd = {
          description = "meshtasticd-daemon privilege user";

          extraGroups = [
            "spi"
            "gpio"
          ];

          group = cfg.group;
          home = cfg.dataDir;
          isSystemUser = true;
        };
      };
    };
  };
}
