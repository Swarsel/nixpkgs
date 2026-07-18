{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.security.rtkit;
in
{
  options.security.rtkit = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Whether to enable the RealtimeKit system service, which hands
        out realtime scheduling priority to user processes on
        demand. For example, PulseAudio and PipeWire use this to
        acquire realtime priority.
      '';

      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs "rtkit" { };

    args = lib.mkOption {
      default = [ ];

      description = ''
        Command-line options for `rtkit-daemon`.
      '';

      example = [
        "--our-realtime-priority=29"
        "--max-realtime-priority=28"
      ];

      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    # To make polkit pickup rtkit policies
    environment.systemPackages = [ cfg.package ];
    security.polkit.enable = true;
    services.dbus.packages = [ cfg.package ];
    systemd.packages = [ cfg.package ];

    systemd.services.rtkit-daemon = {
      serviceConfig = {
        ExecStart = [
          "" # Resets command from upstream unit.
          "${cfg.package}/libexec/rtkit-daemon ${utils.escapeSystemdExecArgs cfg.args}"
        ];

        IPAddressDeny = "any";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = "disconnected";
        # Needs to verify the user of the processes.
        PrivateUsers = false;
        # Needs to access other processes to modify their scheduling modes.
        ProcSubset = "all";
        ProtectClock = true;
        ProtectControlGroups = "strict";
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "default";
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = [ "AF_UNIX" ];
        RestrictNamespaces = true;
        # Canary needs to be realtime.
        RestrictRealtime = false;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "@mount" # Needs chroot(1)
        ];

        UMask = "0777";
      };
    };

    users.groups.rtkit = { };

    users.users.rtkit = {
      description = "RealtimeKit daemon";
      group = "rtkit";
      isSystemUser = true;
    };
  };

  meta = { inherit (pkgs.rtkit.meta) maintainers; };
}
