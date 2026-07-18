{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    getExe
    maintainers
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optional
    ;
  inherit (lib.types)
    path
    str
    port
    bool
    enum
    nullOr
    ;

  stateDir = "/var/lib/tsidp";

  cfg = config.services.tsidp;
in
{
  options.services.tsidp = {
    enable = mkEnableOption "tsidp server";
    package = mkPackageOption pkgs "tsidp" { };

    environmentFile = mkOption {
      default = null;

      description = ''
        Path to an environment file loaded for the tsidp service.

        This can be used to securely store tokens and secrets outside of the world-readable Nix store.

        Example contents of the file:
        ```
        TS_AUTH_KEY=YOUR_TAILSCALE_AUTHKEY
        ```
      '';

      example = "/run/secrets/tsidp";
      type = nullOr path;
    };

    settings = {
      debugAllRequests = mkOption {
        default = false;

        description = ''
          For development. Prints all requests and responses.
        '';

        type = bool;
      };

      debugTsnet = mkOption {
        default = false;

        description = ''
          For development. Enables debug level logging with tsnet connection.
        '';

        type = bool;
      };

      enableFunnel = mkOption {
        default = false;

        description = ''
          Use Tailscale Funnel to make tsidp available on the public internet so it works with SaaS products.
        '';

        type = bool;
      };

      enableSts = mkOption {
        default = true;

        description = ''
          Enable OAuth token exchange using RFC 8693.
        '';

        type = bool;
      };

      hostName = mkOption {
        default = "idp";

        description = ''
          The hostname to use for the tsnet node.
        '';

        type = str;
      };

      localPort = mkOption {
        default = null;
        description = "Listen on localhost:<port>.";
        type = nullOr port;
      };

      logLevel = mkOption {
        default = "info";

        description = ''
          Set logging level: debug, info, warn, error.
        '';

        type = enum [
          "debug"
          "info"
          "warn"
          "error"
        ];
      };

      port = mkOption {
        default = 443;

        description = ''
          Port to listen on (default: 443).
        '';

        type = port;
      };

      useLocalTailscaled = mkOption {
        default = false;

        description = ''
          Use local tailscaled instead of tsnet.
        '';

        type = bool;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.settings.useLocalTailscaled -> config.services.tailscale.enable == true;
        message = "Tailscale service must be enabled if services.tsidp.settings.useLocalTailscaled is used.";
      }
    ];

    systemd.services.tsidp =
      let
        deps = [
          "network.target"
        ]
        ++ optional (cfg.settings.useLocalTailscaled) "tailscaled.service";
      in
      {
        after = deps;
        description = "tsidp";

        environment = {
          HOME = stateDir;
          TAILSCALE_USE_WIP_CODE = "1"; # Needed while tsidp is in development (< v1.0.0).
        };

        restartTriggers = [
          cfg.package
          cfg.environmentFile
        ];

        serviceConfig = {
          # Hardening
          AmbientCapabilities = "";

          BindPaths = mkIf (cfg.settings.useLocalTailscaled) [
            "/var/run/tailscale:/var/run/tailscale"
          ];

          CapabilityBoundingSet = "";
          DeviceAllow = "";
          DevicePolicy = "closed";
          DynamicUser = true;
          EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;

          ExecStart =
            let
              args = lib.cli.toCommandLineShellGNU { } {
                debug-all-requests = cfg.settings.debugAllRequests;
                debug-tsnet = cfg.settings.debugTsnet;
                dir = stateDir;
                enable-sts = cfg.settings.enableSts;
                funnel = cfg.settings.enableFunnel;
                hostname = cfg.settings.hostName;
                local-port = cfg.settings.localPort;
                log = cfg.settings.logLevel;
                port = cfg.settings.port;
                use-local-tailscaled = cfg.settings.useLocalTailscaled;
              };
            in
            "${getExe cfg.package} ${args}";

          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateNetwork = false; # provides the service through network
          PrivateTmp = true;
          PrivateUsers = true;
          ProcSubset = "all"; # tsidp needs access to /proc/net/route
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";

          ReadWritePaths = mkIf (cfg.settings.useLocalTailscaled) [
            "/var/run/tailscale" # needed due to `ProtectSystem = "strict";`
            "/var/lib/tailscale"
          ];

          Restart = "always";
          RestartSec = "15";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
            "AF_NETLINK"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          StateDirectory = baseNameOf stateDir;
          SystemCallArchitectures = "native";
          SystemCallFilter = [ "@system-service" ];
          Type = "simple";
          WorkingDirectory = stateDir;
        };

        wantedBy = [
          "multi-user.target"
          "network-online.target"
        ];

        wants = deps;
      };
  };

  meta.maintainers = with maintainers; [
    akotro
    mikeodr
    yethal
  ];
}
