{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.tang;
in
{
  options.services.tang = {
    enable = lib.mkEnableOption "tang";
    package = lib.mkPackageOption pkgs "tang" { };

    ipAddressAllow = lib.mkOption {
      description = ''
        Whitelist a list of address prefixes.
        Preferably, internal addresses should be used.
      '';

      example = [ "192.168.1.0/24" ];
      type = lib.types.listOf lib.types.str;
    };

    listenStream = lib.mkOption {
      default = [ "7654" ];

      description = ''
        Addresses and/or ports on which tang should listen.
        For detailed syntax see ListenStream in {manpage}`systemd.socket(5)`.
      '';

      example = [
        "198.168.100.1:7654"
        "[2001:db8::1]:7654"
        "7654"
      ];

      type = with lib.types; listOf str;
    };

  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services."tangd@" = {
      description = "Tang server";
      path = [ cfg.package ];

      serviceConfig = {
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "/dev/stdin" ];
        DevicePolicy = "strict";
        DynamicUser = true;
        ExecStart = "${cfg.package}/libexec/tangd %S/tang";
        IPAddressAllow = cfg.ipAddressAllow;
        IPAddressDeny = "any";
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
        RestrictAddressFamilies = [ "AF_UNIX" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "tang";
        StandardError = "journal";
        StandardInput = "socket";
        StandardOutput = "socket";
        StateDirectory = "tang";
        StateDirectoryMode = "700";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0077";
      };
    };

    systemd.sockets.tangd = {
      description = "Tang server";

      socketConfig = {
        Accept = "yes";
        IPAddressAllow = cfg.ipAddressAllow;
        IPAddressDeny = "any";
        ListenStream = cfg.listenStream;
      };

      wantedBy = [ "sockets.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    jfroche
    julienmalka
  ];
}
