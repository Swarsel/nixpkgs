{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.ydotool;
in
{
  options.programs.ydotool = {
    enable = lib.mkEnableOption ''
      ydotoold system service and {command}`ydotool` for members of
      {option}`programs.ydotool.group`.
    '';

    group = lib.mkOption {
      default = "ydotool";

      description = ''
        Group which users must be in to use {command}`ydotool`.
      '';

      type = lib.types.str;
    };
  };

  config =
    let
      runtimeDirectory = "ydotoold";
    in
    lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [ ydotool ];

      environment.variables = {
        YDOTOOL_SOCKET = "/run/${runtimeDirectory}/socket";
      };

      systemd.services.ydotoold = {
        description = "ydotoold - backend for ydotool";
        partOf = [ "multi-user.target" ];

        serviceConfig = {
          CapabilityBoundingSet = "";
          # hardening
          ## allow access to uinput
          DeviceAllow = [ "/dev/uinput" ];
          DevicePolicy = "closed";
          ExecStart = "${lib.getExe' pkgs.ydotool "ydotoold"} --socket-path=${config.environment.variables.YDOTOOL_SOCKET} --socket-perm=0660";
          Group = config.programs.ydotool.group;
          IPAddressDeny = "any";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateNetwork = true;
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
          ## allow creation of unix sockets
          RestrictAddressFamilies = [ "AF_UNIX" ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RuntimeDirectory = runtimeDirectory;
          RuntimeDirectoryMode = "0750";
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
            "~@resources"
          ];

          UMask = "0077";
          # -> systemd-analyze security score 0.7 SAFE 😀
        };

        wantedBy = [ "multi-user.target" ];
      };

      users.groups."${config.programs.ydotool.group}" = { };
    };

  meta = {
    maintainers = with lib.maintainers; [ quantenzitrone ];
  };
}
