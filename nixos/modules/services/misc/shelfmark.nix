{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.shelfmark;
in
{
  options.services.shelfmark = {

    enable = lib.mkEnableOption "Shelfmark, a self-hosted book and audiobook search and download interface";
    package = lib.mkPackageOption pkgs "shelfmark" { };

    environment = lib.mkOption {
      default = { };

      description = ''
        Environment variables to pass to the Shelfmark service.
        See <https://github.com/calibrain/shelfmark/blob/main/docs/environment-variables.md>
        for available options.
      '';

      example = {
        LOG_LEVEL = "DEBUG";
        SEARCH_MODE = "universal";
      };

      type = lib.types.submodule {
        options = {
          CONFIG_DIR = lib.mkOption {
            default = "/var/lib/shelfmark";
            description = "Directory for Shelfmark configuration, database, and artwork cache.";
            type = lib.types.path;
          };

          ENABLE_LOGGING = lib.mkOption {
            apply = toString;
            default = false;
            description = "Whether to enable file logging. Disabled by default since systemd captures console output via journald.";
            type = lib.types.bool;
          };

          FLASK_HOST = lib.mkOption {
            default = "127.0.0.1";
            description = "The IP address to bind the Shelfmark server to.";
            example = "0.0.0.0";
            type = lib.types.str;
          };

          FLASK_PORT = lib.mkOption {
            apply = toString;
            default = 8084;
            description = "TCP port for the Shelfmark web interface.";
            type = lib.types.port;
          };
        };

        freeformType = lib.types.attrsOf lib.types.str;
      };
    };

    openFirewall = lib.mkOption {
      default = false;
      description = "Open the appropriate ports in the firewall for Shelfmark.";
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ (lib.toInt cfg.environment.FLASK_PORT) ];
    };

    systemd.services.shelfmark = {
      inherit (cfg) environment;
      after = [ "network-online.target" ];
      description = "Shelfmark - book and audiobook search and download interface";

      serviceConfig = {
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        DynamicUser = true;
        ExecStart = "${lib.getExe cfg.package} -b ${cfg.environment.FLASK_HOST}:${cfg.environment.FLASK_PORT}";
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

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "shelfmark";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0077";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
}
