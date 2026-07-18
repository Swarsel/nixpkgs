{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  inherit (lib)
    getExe'
    mkEnableOption
    mkIf
    mkPackageOption
    mkOption
    ;

  inherit (lib.types)
    listOf
    enum
    port
    str
    ;

  inherit (utils) escapeSystemdExecArgs;

  cfg = config.services.netbird.server.signal;
in

{
  options.services.netbird.server.signal = {
    enable = mkEnableOption "Netbird's Signal Service";
    package = mkPackageOption pkgs "netbird-signal" { };

    domain = mkOption {
      description = "The domain name for the signal service.";
      type = str;
    };

    enableNginx = mkEnableOption "Nginx reverse-proxy for the netbird signal service";

    extraOptions = mkOption {
      default = [ ];

      description = ''
        Additional options given to netbird-signal as commandline arguments.
      '';

      type = listOf str;
    };

    logLevel = mkOption {
      default = "INFO";
      description = "Log level of the netbird signal service.";

      type = enum [
        "ERROR"
        "WARN"
        "INFO"
        "DEBUG"
      ];
    };

    metricsPort = mkOption {
      default = 9091;
      description = "Internal port of the metrics server.";
      type = port;
    };

    port = mkOption {
      default = 8012;
      description = "Internal port of the signal server.";
      type = port;
    };
  };

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.port != cfg.metricsPort;
        message = "The primary listen port cannot be the same as the listen port for the metrics endpoint";
      }
    ];

    services.nginx = mkIf cfg.enableNginx {
      enable = true;

      virtualHosts.${cfg.domain} = {
        locations."/signalexchange.SignalExchange/".extraConfig = ''
          # This is necessary so that grpc connections do not get closed early
          # see https://stackoverflow.com/a/67805465
          client_body_timeout 1d;

          grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

          grpc_pass grpc://localhost:${toString cfg.port};
          grpc_read_timeout 1d;
          grpc_send_timeout 1d;
          grpc_socket_keepalive on;
        '';
      };
    };

    systemd.services.netbird-signal = {
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = escapeSystemdExecArgs (
          [
            (getExe' cfg.package "netbird-signal")
            "run"
            # Port to listen on
            "--port"
            cfg.port
            # Port the internal prometheus server listens on
            "--metrics-port"
            cfg.metricsPort
            # Log to stdout
            "--log-file"
            "console"
            # Log level
            "--log-level"
            cfg.logLevel
          ]
          ++ cfg.extraOptions
        );

        # hardening
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = true;
        RemoveIPC = true;
        Restart = "always";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "netbird-mgmt";
        StateDirectory = "netbird-mgmt";
        WorkingDirectory = "/var/lib/netbird-mgmt";
      };

      stopIfChanged = false;
      wantedBy = [ "multi-user.target" ];
    };
  };
}
