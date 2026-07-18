{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.endlessh;
in
{
  options.services.endlessh = {
    enable = lib.mkEnableOption "endlessh service";

    extraOptions = lib.mkOption {
      default = [ ];

      description = ''
        Additional command line options to pass to the endlessh daemon.
      '';

      example = [
        "-6"
        "-d 9000"
        "-v"
      ];

      type = with lib.types; listOf str;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Whether to open a firewall port for the SSH listener.
      '';

      type = lib.types.bool;
    };

    port = lib.mkOption {
      default = 2222;

      description = ''
        Specifies on which port the endlessh daemon listens for SSH
        connections.

        Setting this to `22` may conflict with {option}`services.openssh`.
      '';

      example = 22;
      type = lib.types.port;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = with cfg; lib.optionals openFirewall [ port ];

    systemd.services.endlessh = {
      description = "SSH tarpit";
      documentation = [ "man:endlessh(1)" ];
      requires = [ "network.target" ];

      serviceConfig =
        let
          needsPrivileges = cfg.port < 1024;
          capabilities = [ "" ] ++ lib.optionals needsPrivileges [ "CAP_NET_BIND_SERVICE" ];
          rootDirectory = "/run/endlessh";
        in
        {
          AmbientCapabilities = capabilities;
          BindReadOnlyPaths = [ builtins.storeDir ];
          CapabilityBoundingSet = capabilities;
          DynamicUser = true;

          ExecStart =
            with cfg;
            lib.concatStringsSep " " (
              [
                "${pkgs.endlessh}/bin/endlessh"
                "-p ${toString port}"
              ]
              ++ extraOptions
            );

          InaccessiblePaths = [ "-+${rootDirectory}" ];
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          PrivateUsers = !needsPrivileges;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "noaccess";
          ProtectSystem = "strict";
          RemoveIPC = true;
          Restart = "always";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RootDirectory = rootDirectory;
          RuntimeDirectory = baseNameOf rootDirectory;
          RuntimeDirectoryMode = "700";
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@resources"
            "~@privileged"
          ];

          UMask = "0077";
        };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ azahi ];
}
