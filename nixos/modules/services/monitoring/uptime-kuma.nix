{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.uptime-kuma;
in
{

  options = {
    services.uptime-kuma = {
      enable = lib.mkEnableOption "Uptime Kuma, this assumes a reverse proxy to be set";
      package = lib.mkPackageOption pkgs "uptime-kuma" { };
      appriseSupport = lib.mkEnableOption "apprise support for notifications";

      settings = lib.mkOption {
        default = { };

        description = ''
          Additional configuration for Uptime Kuma, see
          <https://github.com/louislam/uptime-kuma/wiki/Environment-Variables>
          for supported values.
        '';

        example = {
          NODE_EXTRA_CA_CERTS = lib.literalExpression "config.security.pki.caBundle";
          PORT = "4000";
          UPTIME_KUMA_DB_HOSTNAME = "localhost";
          UPTIME_KUMA_DB_NAME = "uptime-kuma";
          UPTIME_KUMA_DB_PASSWORD = "uptime-kuma";
          UPTIME_KUMA_DB_TYPE = "mariadb";
          UPTIME_KUMA_DB_USERNAME = "uptime-kuma";
        };

        type = lib.types.submodule { freeformType = with lib.types; attrsOf str; };
      };
    };
  };

  config = lib.mkIf cfg.enable {

    services.uptime-kuma.settings = {
      DATA_DIR = "/var/lib/uptime-kuma/";
      HOST = lib.mkDefault "127.0.0.1";
      NODE_ENV = lib.mkDefault "production";
      PORT = lib.mkDefault "3001";
      UPTIME_KUMA_DB_TYPE = lib.mkDefault "sqlite";
    };

    systemd.services.uptime-kuma = {
      after = [ "network.target" ];
      description = "Uptime Kuma";
      environment = cfg.settings;
      path = with pkgs; [ unixtools.ping ] ++ lib.optional cfg.appriseSupport apprise;

      serviceConfig = {
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/uptime-kuma-server";
        LockPersonality = true;
        MemoryDenyWriteExecute = false; # enabling it breaks execution
        MountAPIVFS = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = "strict";
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
          "AF_UNIX"
          "AF_NETLINK"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "uptime-kuma";
        StateDirectoryMode = "750";
        SystemCallArchitectures = "native";
        Type = "simple";
        UMask = 27;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.julienmalka ];
}
