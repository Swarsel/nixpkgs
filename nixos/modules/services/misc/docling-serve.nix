{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;

  cfg = config.services.docling-serve;
in
{
  options = {
    services.docling-serve = {
      enable = lib.mkEnableOption "Docling Serve server";
      package = lib.mkPackageOption pkgs "docling-serve" { };

      environment = lib.mkOption {
        default = {
          DOCLING_SERVE_ENABLE_UI = "False";
        };

        description = ''
          Extra environment variables for Docling Serve.
          For more details see <https://github.com/docling-project/docling-serve/blob/main/docs/configuration.md>
        '';

        example = ''
          {
            DOCLING_SERVE_ENABLE_UI = "True";
          }
        '';

        type = types.attrsOf types.str;
      };

      environmentFile = lib.mkOption {
        default = null;

        description = ''
          Environment file to be passed to the systemd service.
          Useful for passing secrets to the service to prevent them from being
          world-readable in the Nix store.
        '';

        example = "/var/lib/secrets/doclingServeSecrets";
        type = lib.types.nullOr lib.types.path;
      };

      host = lib.mkOption {
        default = "127.0.0.1";

        description = ''
          The host address which the Docling Serve server HTTP interface listens to.
        '';

        example = "0.0.0.0";
        type = types.str;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Whether to open the firewall for Docling Serve.
          This adds `services.Docling Serve.port` to `networking.firewall.allowedTCPPorts`.
        '';

        type = types.bool;
      };

      port = lib.mkOption {
        default = 5001;

        description = ''
          Which port the Docling Serve server listens to.
        '';

        example = 11111;
        type = types.port;
      };

      stateDir = lib.mkOption {
        default = "/var/lib/docling-serve";
        description = "State directory of Docling Serve.";
        example = "/home/foo";
        type = types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };

    systemd.services.docling-serve = {
      after = [ "network.target" ];
      description = "Running Docling as an API service";

      environment = {
        EASYOCR_MODULE_PATH = ".";
        HF_HOME = ".";
        MPLCONFIGDIR = ".";
      }
      // cfg.environment;

      serviceConfig = {
        CapabilityBoundingSet = "";
        DevicePolicy = "closed";
        DynamicUser = true;
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = "${lib.getExe cfg.package} run --host \"${cfg.host}\" --port ${toString cfg.port}";
        LockPersonality = true;
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

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RuntimeDirectory = "docling-serve";
        RuntimeDirectoryMode = "0755";
        StateDirectory = "docling-serve";
        SystemCallArchitectures = "native";
        UMask = "0077";
        WorkingDirectory = cfg.stateDir;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ ];
}
