{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.echoip;
in
{
  options.services.echoip = {
    enable = lib.mkEnableOption "echoip";
    package = lib.mkPackageOption pkgs "echoip" { };
    enablePortLookup = lib.mkEnableOption "port lookup";
    enableReverseHostnameLookups = lib.mkEnableOption "reverse hostname lookups";

    extraArgs = lib.mkOption {
      default = [ ];
      description = "Extra command line arguments to pass to echoip. See <https://github.com/mpolden/echoip> for details.";
      type = lib.types.listOf lib.types.str;
    };

    listenAddress = lib.mkOption {
      default = ":8080";
      description = "The address echoip should listen on";
      example = "127.0.0.1:8000";
      type = lib.types.str;
    };

    remoteIpHeader = lib.mkOption {
      default = null;
      description = "Header to trust for remote IP, if present";
      example = "X-Real-IP";
      type = lib.types.nullOr lib.types.str;
    };

    virtualHost = lib.mkOption {
      default = null;

      description = ''
        Name of the nginx virtual host to use and setup. If null, do not setup anything.
      '';

      type = lib.types.nullOr lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services.echoip = lib.mkIf (cfg.virtualHost != null) {
      listenAddress = lib.mkDefault "127.0.0.1:8080";
      remoteIpHeader = "X-Real-IP";
    };

    services.nginx = lib.mkIf (cfg.virtualHost != null) {
      enable = true;

      virtualHosts.${cfg.virtualHost} = {
        locations."/" = {
          proxyPass = "http://${cfg.listenAddress}";
          recommendedProxySettings = true;
        };
      };
    };

    systemd.services.echoip = {
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
            "-l"
            cfg.listenAddress
          ]
          ++ lib.optional cfg.enablePortLookup "-p"
          ++ lib.optional cfg.enableReverseHostnameLookups "-r"
          ++ lib.optionals (cfg.remoteIpHeader != null) [
            "-H"
            cfg.remoteIpHeader
          ]
          ++ cfg.extraArgs
        );

        Group = "echoip";
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
        RestrictAddressFamilies = [ "AF_INET AF_INET6 AF_UNIX" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
          "setrlimit"
        ];

        UMask = "0077";
        User = "echoip";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ defelo ];
}
