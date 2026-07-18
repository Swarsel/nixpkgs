{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  cfg = config.services.croc;
  rootDir = "/run/croc";
in
{
  options.services.croc = {
    enable = lib.mkEnableOption "croc relay";
    debug = lib.mkEnableOption "debug logs";
    openFirewall = lib.mkEnableOption "opening of the peer port(s) in the firewall";

    pass = lib.mkOption {
      default = "pass123";
      description = "Password or passwordfile for the relay.";
      type = with types; either path str;
    };

    ports = lib.mkOption {
      default = [
        9009
        9010
        9011
        9012
        9013
      ];

      description = "Ports of the relay.";
      type = with types; listOf port;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall cfg.ports;

    systemd.services.croc = {
      after = [ "network.target" ];

      serviceConfig = {
        # The following options are only for optimizing:
        # systemd-analyze security croc
        AmbientCapabilities = "";

        BindReadOnlyPaths = [
          builtins.storeDir
        ]
        ++ lib.optional (types.path.check cfg.pass) cfg.pass;

        CapabilityBoundingSet = "";
        # ProtectClock= adds DeviceAllow=char-rtc r
        DeviceAllow = "";
        DynamicUser = true;

        ExecStart = "${pkgs.croc}/bin/croc --pass '${cfg.pass}' ${lib.optionalString cfg.debug "--debug"} relay --ports ${
          lib.concatMapStringsSep "," toString cfg.ports
        }";

        # Avoid mounting rootDir in the own rootDir of ExecStart='s mount namespace.
        InaccessiblePaths = [ "-+${rootDir}" ];
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        MountAPIVFS = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateNetwork = lib.mkDefault false;
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
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RootDirectory = rootDir;
        # Create rootDir in the host's mount namespace.
        RuntimeDirectory = [ (baseNameOf rootDir) ];
        RuntimeDirectoryMode = "700";
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";

        SystemCallFilter = [
          "@system-service"
          "~@aio"
          "~@keyring"
          "~@memlock"
          "~@privileged"
          "~@setuid"
          "~@sync"
          "~@timer"
        ];

        # This is for BindReadOnlyPaths=
        # to allow traversal of directories they create in RootDirectory=.
        UMask = "0066";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    hax404
    julm
  ];
}
