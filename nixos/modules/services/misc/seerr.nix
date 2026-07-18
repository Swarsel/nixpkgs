{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.seerr;
  # 26.05 introduced a breaking change which is guarded behind stateVersion to avoid
  # breaking users.
  useNewConfigLocation = lib.versionAtLeast config.system.stateVersion "26.05";
in
{
  imports = [
    (lib.mkRenamedOptionModule [ "services" "jellyseerr" ] [ "services" "seerr" ])
  ];

  options.services.seerr = {
    enable = lib.mkEnableOption "Seerr, a requests manager for Jellyfin";
    package = lib.mkPackageOption pkgs "seerr" { };

    configDir = lib.mkOption {
      default = if useNewConfigLocation then "/var/lib/seerr/" else "/var/lib/jellyseerr/config";
      description = "Config data directory";
      type = lib.types.path;
    };

    openFirewall = lib.mkOption {
      default = false;
      description = "Open port in the firewall for the Seerr web interface.";
      type = lib.types.bool;
    };

    port = lib.mkOption {
      default = 5055;
      description = "The port which the Seerr web UI should listen to.";
      type = lib.types.port;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.seerr = {
      after = [ "network.target" ];
      description = "Seerr, a requests manager for Jellyfin";

      environment = {
        CONFIG_DIRECTORY = cfg.configDir;
        PORT = toString cfg.port;
      };

      serviceConfig = {
        DynamicUser = true;
        ExecStart = lib.getExe cfg.package;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RemoveIPC = true;
        Restart = "on-failure";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        # Note: this should be a parent of configDir.
        StateDirectory = if useNewConfigLocation then "seerr" else "jellyseerr";
        Type = "exec";
      };

      unitConfig.RequiresMountsFor = [ cfg.configDir ];
      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    camillemndn
    fallenbagel
  ];
}
