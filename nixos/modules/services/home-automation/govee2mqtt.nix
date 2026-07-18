{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.govee2mqtt;
in
{
  options.services.govee2mqtt = {
    enable = lib.mkEnableOption "Govee2MQTT";
    package = lib.mkPackageOption pkgs "govee2mqtt" { };

    environmentFile = lib.mkOption {
      description = ''
        Environment file as defined in {manpage}`systemd.exec(5)`.

        See upstream documentation <https://github.com/wez/govee2mqtt/blob/main/docs/CONFIG.md>.
      '';

      example = "/var/lib/govee2mqtt/govee2mqtt.env";
      type = lib.types.path;
    };

    group = lib.mkOption {
      default = "govee2mqtt";
      description = "Group under which Govee2MQTT should run.";
      type = lib.types.str;
    };

    user = lib.mkOption {
      default = "govee2mqtt";
      description = "User under which Govee2MQTT should run.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.govee2mqtt = {
      after = [
        "network.target"
        "network-online.target"
      ];

      description = "Govee2MQTT Service";
      requires = [ "network-online.target" ];

      serviceConfig = {
        # Hardening
        AmbientCapabilities = "";
        CacheDirectory = "govee2mqtt";
        CapabilityBoundingSet = "";

        Environment = [
          "GOVEE_CACHE_DIR=/var/cache/govee2mqtt"
        ];

        EnvironmentFile = cfg.environmentFile;

        ExecStart =
          "${lib.getExe cfg.package} serve --govee-iot-key=/var/lib/govee2mqtt/iot.key --govee-iot-cert=/var/lib/govee2mqtt/iot.cert"
          + " --amazon-root-ca=${pkgs.cacert.unbundled}/etc/ssl/certs/Amazon_Root_CA_1:66c9fcf99bf8c0a39e2f0788a43e696365bca.crt";

        Group = cfg.group;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
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
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "govee2mqtt";
        SystemCallArchitectures = "native";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users = {
      groups.${cfg.group} = { };

      users.${cfg.user} = {
        inherit (cfg) group;
        description = "Govee2MQTT service user";
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ SuperSandro2000 ];
}
