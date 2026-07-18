{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;

  cfg = config.services.litellm;
  settingsFormat = pkgs.formats.yaml { };

  tiktokenEncodings = {
    cl100k_base = {
      hash = "sha256-Ijkht27pm96ZW3/3OFE+7xAPtR0YyTWXoRO8/+hlsqc=";
      url = "https://openaipublic.blob.core.windows.net/encodings/cl100k_base.tiktoken";
    };
  };

  tiktokenCacheEntries = lib.mapAttrsToList (
    _: encoding:
    let
      cacheKey = builtins.hashString "sha1" encoding.url;
      sourceFile = pkgs.fetchurl {
        inherit (encoding) url hash;
      };
    in
    {
      inherit cacheKey sourceFile;
    }
  ) tiktokenEncodings;

  seedTiktokenCacheScript = pkgs.writeShellScript "litellm-seed-tiktoken-cache" ''
    set -eu

    mkdir -p "$CUSTOM_TIKTOKEN_CACHE_DIR"

    ${lib.concatMapStringsSep "\n" (entry: ''
      ln -sf ${entry.sourceFile} "$CUSTOM_TIKTOKEN_CACHE_DIR/${entry.cacheKey}"
    '') tiktokenCacheEntries}
  '';
in
{
  options = {
    services.litellm = {
      enable = lib.mkEnableOption "LiteLLM server";
      package = lib.mkPackageOption pkgs "litellm" { };

      environment = lib.mkOption {
        default = {
          ANONYMIZED_TELEMETRY = "False";
          DO_NOT_TRACK = "True";
          SCARF_NO_ANALYTICS = "True";
        };

        description = ''
          Extra environment variables for LiteLLM.
        '';

        example = ''
          {
            NO_DOCS="True";
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

        example = "/var/lib/secrets/liteLLMSecrets";
        type = lib.types.nullOr lib.types.path;
      };

      host = lib.mkOption {
        default = "127.0.0.1";

        description = ''
          The host address which the LiteLLM server HTTP interface listens to.
        '';

        example = "0.0.0.0";
        type = types.str;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Whether to open the firewall for LiteLLM.
          This adds `services.litellm.port` to `networking.firewall.allowedTCPPorts`.
        '';

        type = types.bool;
      };

      port = lib.mkOption {
        default = 8080;

        description = ''
          Which port the LiteLLM server listens to.
        '';

        example = 11111;
        type = types.port;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Configuration for LiteLLM.
          See <https://docs.litellm.ai/docs/proxy/configs> for more.
        '';

        type = types.submodule {
          options = {
            environment_variables = lib.mkOption {
              default = { };

              description = ''
                Environment variables to pass to the Lite
              '';

              type = settingsFormat.type;
            };

            general_settings = lib.mkOption {
              default = { };

              description = ''
                LiteLLM Server settings
              '';

              type = settingsFormat.type;
            };

            litellm_settings = lib.mkOption {
              default = { };

              description = ''
                LiteLLM Module settings
              '';

              type = settingsFormat.type;
            };

            model_list = lib.mkOption {
              default = [ ];

              description = ''
                List of supported models on the server, with model-specific configs.
              '';

              type = settingsFormat.type;
            };

            router_settings = lib.mkOption {
              default = { };

              description = ''
                LiteLLM Router settings
              '';

              type = settingsFormat.type;
            };
          };

          freeformType = settingsFormat.type;
        };
      };

      stateDir = lib.mkOption {
        default = "/var/lib/litellm";
        description = "State directory of LiteLLM.";
        example = "/home/foo";
        type = types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };

    systemd.services.litellm = {
      after = [ "network.target" ];
      description = "LLM Gateway to provide model access, fallbacks and spend tracking across 100+ LLMs.";

      environment = {
        # LiteLLM sets TIKTOKEN_CACHE_DIR internally from this variable.
        CUSTOM_TIKTOKEN_CACHE_DIR = "${cfg.stateDir}/tiktoken-cache";
        # LiteLLM will try to "restructure" (rewrite) its packaged UI files on startup
        # to support extensionless routes (e.g. `/ui/login`). In Nix builds the packaged
        # UI lives in the read-only Nix store, so point it at a writable runtime path.
        LITELLM_NON_ROOT = "true";
        LITELLM_UI_PATH = "${cfg.stateDir}/ui";
      }
      // cfg.environment;

      serviceConfig =
        let
          configFile = settingsFormat.generate "config.yaml" cfg.settings;
        in
        {
          DevicePolicy = "closed";
          DynamicUser = true;
          EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
          ExecStart = "${lib.getExe cfg.package} --host \"${cfg.host}\" --port ${toString cfg.port} --config ${configFile}";

          ExecStartPre = [
            # Seed tokenizer cache with fixed-output files so startup does not
            # depend on outbound network access.
            seedTiktokenCacheScript

            # LiteLLM may rewrite/copy UI assets with read-only permissions
            # during previous runs; normalize writability on each start.
            "${pkgs.runtimeShell} -euc 'chmod -R u+rwX ${cfg.stateDir}/ui'"
          ];

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
          RuntimeDirectory = "litellm";
          RuntimeDirectoryMode = "0755";

          StateDirectory = [
            "litellm"
            "litellm/ui"
            "litellm/tiktoken-cache"
          ];

          SystemCallArchitectures = "native";
          UMask = "0077";
          WorkingDirectory = cfg.stateDir;
        };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.stateDir}/ui' 0700 - - - -"
      "d '${cfg.stateDir}/tiktoken-cache' 0700 - - - -"
    ];
  };

  meta.maintainers = [ ];
}
