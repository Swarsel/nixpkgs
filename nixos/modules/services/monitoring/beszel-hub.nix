{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.beszel.hub;
in
{
  options.services.beszel.hub = {
    enable = lib.mkEnableOption "beszel hub";
    package = lib.mkPackageOption pkgs "beszel" { };

    dataDir = lib.mkOption {
      default = "/var/lib/beszel-hub";
      description = "Data directory of beszel-hub.";
      type = lib.types.path;
    };

    environment = lib.mkOption {
      default = { };

      description = ''
        Environment variables passed to the systemd service.
        See <https://www.beszel.dev/guide/environment-variables#hub> for available options.
      '';

      example = {
        DISABLE_PASSWORD_AUTH = "true";
      };

      type = with lib.types; attrsOf str;
    };

    environmentFile = lib.mkOption {
      default = null;

      description = ''
        Environment file to be passed to the systemd service.
        Useful for passing secrets to the service to prevent them from being
        world-readable in the Nix store. See {manpage}`systemd.exec(5)`.
      '';

      type = lib.types.nullOr lib.types.path;
    };

    host = lib.mkOption {
      default = "127.0.0.1";
      description = "Host or address this beszel hub listens on.";
      example = "0.0.0.0";
      type = lib.types.str;
    };

    port = lib.mkOption {
      default = 8090;
      description = "Port for this beszel hub to listen on.";
      example = 3002;
      type = lib.types.port;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.beszel-hub = {
      after = [ "network-online.target" ];
      description = "Beszel Server Monitoring Web App";
      environment = cfg.environment;

      serviceConfig = {
        DevicePolicy = "closed";
        DynamicUser = true;
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;

        ExecStart = ''
          ${cfg.package}/bin/beszel-hub serve --http='${cfg.host}:${toString cfg.port}'
        '';

        ExecStartPre = [
          "${cfg.package}/bin/beszel-hub migrate up"
          "${cfg.package}/bin/beszel-hub history-sync"
        ];

        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = "strict";
        ProtectHome = "read-only";
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        ReadWritePaths = cfg.dataDir;
        Restart = "on-failure";
        RestartSec = "30s";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = baseNameOf cfg.dataDir;
        StateDirectory = baseNameOf cfg.dataDir;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = [ "@system-service" ];
        UMask = 27;
        User = "beszel-hub";
        WorkingDirectory = cfg.dataDir;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    BonusPlay
    arunoruto
  ];
}
