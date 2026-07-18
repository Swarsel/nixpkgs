{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.whoami;
in

{
  options.services.whoami = {
    enable = lib.mkEnableOption "whoami";
    package = lib.mkPackageOption pkgs "whoami" { };

    extraArgs = lib.mkOption {
      default = [ ];
      description = "Extra command line arguments to pass to whoami. See <https://github.com/traefik/whoami#flags> for details.";
      type = lib.types.listOf lib.types.str;
    };

    port = lib.mkOption {
      default = 8000;
      description = "The port whoami should listen on.";
      type = lib.types.port;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.whoami = {
      after = [ "network-online.target" ];

      serviceConfig = {
        # Hardening
        AmbientCapabilities = "";
        CapabilityBoundingSet = [ "" ];
        DevicePolicy = "closed";
        DynamicUser = true;

        ExecStart = lib.escapeShellArgs (
          [
            (lib.getExe cfg.package)
            "-port"
            cfg.port
          ]
          ++ cfg.extraArgs
        );

        Group = "whoami";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
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
        RestrictAddressFamilies = [ "AF_INET AF_INET6" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SocketBindAllow = "tcp:${toString cfg.port}";
        SocketBindDeny = "any";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0077";
        User = "whoami";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ defelo ];
}
