{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;

  cfg = config.services.open-webui;
in
{
  options = {
    services.open-webui = {
      enable = lib.mkEnableOption "Open-WebUI server";
      package = lib.mkPackageOption pkgs "open-webui" { };

      environment = lib.mkOption {
        default = {
          ANONYMIZED_TELEMETRY = "False";
          DO_NOT_TRACK = "True";
          SCARF_NO_ANALYTICS = "True";
        };

        description = ''
          Extra environment variables for Open-WebUI.
          For more details see <https://docs.openwebui.com/reference/env-configuration>
        '';

        example = ''
          {
            OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
            # Disable authentication
            WEBUI_AUTH = "False";
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

        example = "/var/lib/secrets/openWebuiSecrets";
        type = lib.types.nullOr lib.types.path;
      };

      host = lib.mkOption {
        default = "127.0.0.1";

        description = ''
          The host address which the Open-WebUI server HTTP interface listens to.
        '';

        example = "0.0.0.0";
        type = types.str;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Whether to open the firewall for Open-WebUI.
          This adds `services.open-webui.port` to `networking.firewall.allowedTCPPorts`.
        '';

        type = types.bool;
      };

      port = lib.mkOption {
        default = 8080;

        description = ''
          Which port the Open-WebUI server listens to.
        '';

        example = 11111;
        type = types.port;
      };

      stateDir = lib.mkOption {
        default = "/var/lib/open-webui";
        description = "State directory of Open-WebUI.";
        example = "/home/foo";
        type = types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };

    systemd.services.open-webui = {
      after = [ "network.target" ];
      description = "User-friendly WebUI for LLMs";

      environment = {
        DATA_DIR = "${cfg.stateDir}/data";
        HF_HOME = "${cfg.stateDir}/hf_home";
        SENTENCE_TRANSFORMERS_HOME = "${cfg.stateDir}/transformers_home";
        STATIC_DIR = "${cfg.stateDir}/static";
        WEBUI_URL = "http://localhost:${toString cfg.port}";
      }
      // cfg.environment;

      # backwards compatability migration
      preStart = ''
        if [ -d "${cfg.stateDir}/data" ] && [ -n "$(ls -A "${cfg.stateDir}/data" 2>/dev/null)" ]; then
          exit 0
        fi

        mkdir -p "${cfg.stateDir}/data"

        [ -f "${cfg.stateDir}/webui.db" ] && mv "${cfg.stateDir}/webui.db" "${cfg.stateDir}/data/"

        for dir in cache uploads vector_db; do
          [ -d "${cfg.stateDir}/$dir" ] && mv "${cfg.stateDir}/$dir" "${cfg.stateDir}/data/"
        done

        exit 0
      '';

      serviceConfig = {
        CapabilityBoundingSet = "";

        DeviceAllow = [
          # CUDA
          # https://docs.nvidia.com/dgx/pdf/dgx-os-5-user-guide.pdf
          "char-nvidiactl"
          "char-nvidia-caps"
          "char-nvidia-frontend"
          "char-nvidia-uvm"
          # ROCm
          "char-drm"
          "char-fb"
          "char-kfd"
          # WSL (Windows Subsystem for Linux)
          "/dev/dxg"
        ];

        DevicePolicy = "closed";
        DynamicUser = true;
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = "${lib.getExe cfg.package} serve --host \"${cfg.host}\" --port ${toString cfg.port}";
        LockPersonality = true;
        MemoryDenyWriteExecute = false; # onnxruntime/capi/onnxruntime_pybind11_state.so: cannot enable executable stack as shared object requires: Permission Denied
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "all"; # Error in cpuinfo: failed to parse processor information from /proc/cpuinfo
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
        RuntimeDirectory = "open-webui";
        RuntimeDirectoryMode = "0755";
        StateDirectory = "open-webui";
        SupplementaryGroups = [ "render" ]; # for rocm to access /dev/dri/renderD* devices
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        UMask = "0077";
        WorkingDirectory = cfg.stateDir;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ shivaraj-bh ];
}
