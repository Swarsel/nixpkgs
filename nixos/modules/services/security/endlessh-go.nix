{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.endlessh-go;
in
{
  options.services.endlessh-go = {
    enable = lib.mkEnableOption "endlessh-go service";
    package = lib.mkPackageOption pkgs "endlessh-go" { };

    extraOptions = lib.mkOption {
      default = [ ];

      description = ''
        Additional command line options to pass to the endlessh-go daemon.
      '';

      example = [
        "-conn_type=tcp4"
        "-max_clients=8192"
      ];

      type = with lib.types; listOf str;
    };

    listenAddress = lib.mkOption {
      default = "0.0.0.0";

      description = ''
        Interface address to bind the endlessh-go daemon to SSH connections.
      '';

      example = "[::]";
      type = lib.types.str;
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
        Specifies on which port the endlessh-go daemon listens for SSH
        connections.

        Setting this to `22` may conflict with {option}`services.openssh`.
      '';

      example = 22;
      type = lib.types.port;
    };

    prometheus = {
      enable = lib.mkEnableOption "Prometheus integration";

      listenAddress = lib.mkOption {
        default = "0.0.0.0";

        description = ''
          Interface address to bind the endlessh-go daemon to answer Prometheus
          queries.
        '';

        example = "[::]";
        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 2112;

        description = ''
          Specifies on which port the endlessh-go daemon listens for Prometheus
          queries.
        '';

        example = 9119;
        type = lib.types.port;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = with cfg; lib.optionals openFirewall [ port ];

    systemd.services.endlessh-go = {
      description = "SSH tarpit";
      requires = [ "network.target" ];

      serviceConfig =
        let
          needsPrivileges = cfg.port < 1024 || cfg.prometheus.port < 1024;
          capabilities = [ "" ] ++ lib.optionals needsPrivileges [ "CAP_NET_BIND_SERVICE" ];
          rootDirectory = "/run/endlessh-go";
        in
        {
          AmbientCapabilities = capabilities;

          BindReadOnlyPaths = [
            builtins.storeDir
            "-/etc/hosts"
            "-/etc/localtime"
            "-/etc/nsswitch.conf"
            "-/etc/resolv.conf"
          ];

          CapabilityBoundingSet = capabilities;
          DynamicUser = true;

          ExecStart =
            with cfg;
            lib.concatStringsSep " " (
              [
                (lib.getExe cfg.package)
                "-logtostderr"
                "-host=${listenAddress}"
                "-port=${toString port}"
              ]
              ++ lib.optionals prometheus.enable [
                "-enable_prometheus"
                "-prometheus_host=${prometheus.listenAddress}"
                "-prometheus_port=${toString prometheus.port}"
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
            "~@privileged"
          ];

          UMask = "0077";
        };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ ];
}
