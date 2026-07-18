{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.llama-swap;
  settingsFormat = pkgs.formats.yaml { };
  configFile = settingsFormat.generate "config.yaml" cfg.settings;
in
{
  options.services.llama-swap = {
    enable = lib.mkEnableOption "the llama-swap service";
    package = lib.mkPackageOption pkgs "llama-swap" { };

    listenAddress = lib.mkOption {
      default = "localhost";

      description = ''
        Address that llama-swap listens on.
      '';

      example = "0.0.0.0";
      type = lib.types.str;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Whether to open the firewall for llama-swap.
        This adds {option}`port` to [](#opt-networking.firewall.allowedTCPPorts).
      '';

      type = lib.types.bool;
    };

    port = lib.mkOption {
      default = 8080;

      description = ''
        Port that llama-swap listens on.
      '';

      example = 11343;
      type = lib.types.port;
    };

    settings = lib.mkOption {
      description = ''
        llama-swap configuration. Refer to the [llama-swap example configuration](https://github.com/mostlygeek/llama-swap/blob/main/config.example.yaml)
        for details on supported values.
      '';

      example = lib.literalExpression ''
        let
          llama-cpp = pkgs.llama-cpp.override { rocmSupport = true; };
          llama-server = lib.getExe' llama-cpp "llama-server";
        in
        {
          healthCheckTimeout = 60;
          models = {
            "some-model" = {
              cmd = "''${llama-server} --port ''${PORT} -m /var/lib/llama-cpp/models/some-model.gguf -ngl 0 --no-webui";
              aliases = [
                "the-best"
              ];
            };
            "other-model" = {
              proxy = "http://127.0.0.1:5555";
              cmd = "''${llama-server} --port 5555 -m /var/lib/llama-cpp/models/other-model.gguf -ngl 0 -c 4096 -np 4 --no-webui";
              concurrencyLimit = 4;
            };
          };
        };
      '';

      type = lib.types.submodule { freeformType = settingsFormat.type; };
    };

    tls = {
      enable = lib.mkEnableOption "TLS encryption";

      certFile = lib.mkOption {
        default = null;

        description = ''
          Path to the TLS certificate file. This certificate will be offered to,
          and may be verified by, clients.
        '';

        example = "/path/to/cert.pem";
        type = lib.types.nullOr lib.types.path;
      };

      keyFile = lib.mkOption {
        default = null;

        description = ''
          Path to the TLS private key file. This key will be used to decrypt,
          data received from clients.
        '';

        example = "/path/to/key.pem";
        type = lib.types.nullOr lib.types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.tls.enable -> cfg.tls.certFile != null;
        message = "Please provide a certificate to use for TLS encryption.";
      }
      {
        assertion = cfg.tls.enable -> cfg.tls.keyFile != null;
        message = "Please provide a private key to use for TLS encryption.";
      }
    ];

    networking.firewall = lib.mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };

    systemd.services.llama-swap = {
      after = [ "network.target" ];
      description = "Model swapping for LLaMA C++ Server (or any local OpenAPI compatible server)";

      serviceConfig = {
        CapabilityBoundingSet = "";
        # hardening
        DynamicUser = true;

        ExecStart = "${lib.getExe cfg.package} ${
          lib.escapeShellArgs (
            [
              "--listen=${cfg.listenAddress}:${toString cfg.port}"
              "--config=${configFile}"
            ]
            ++ lib.optionals cfg.tls.enable [
              "--tls-cert-file=${cfg.tls.certFile}"
              "--tls-key-file=${cfg.tls.keyFile}"
            ]
          )
        }";

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        # for GPU acceleration
        PrivateDevices = false;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
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
        Restart = "on-failure";
        RestartSec = 3;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        Type = "exec";
        WorkingDirectory = "/tmp";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    jk
    podium868909
  ];
}
