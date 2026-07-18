{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  inherit (lib)
    getExe
    mkOption
    mkEnableOption
    mkPackageOption
    mkIf
    types
    ;

  cfg = config.services.perses;

  settingsFormat = pkgs.formats.yaml { };

  configPath = "/run/perses/config.yaml";
  secretsReplacement = utils.genJqSecretsReplacement {
    loadCredential = true;
  } cfg.settings configPath;

in
{
  options.services.perses = {
    enable = mkEnableOption "perses";
    package = mkPackageOption pkgs "perses" { };

    extraOptions = mkOption {
      default = [ ];
      description = "Additional options passed to perses daemon.";

      example = [
        "-web.telemetry-path=/metrics"
      ];

      type = types.listOf types.str;
    };

    listenAddress = mkOption {
      default = "";

      description = ''
        Address to listen on. Empty string will listen on all interfaces.
      '';

      type = types.str;
    };

    port = mkOption {
      default = 8080;

      description = ''
        Perses Web interface port.
      '';

      type = types.port;
    };

    settings = mkOption {
      default = { };

      description = ''
        Perses settings. See <https://perses.dev/perses/docs/configuration/configuration/> for available options.
        You can specify secret values in this configuration by setting `somevalue._secret = "/path/to/file"` instead of setting `somevalue` directly.
      '';

      type = types.submodule {
        freeformType = settingsFormat.type;
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.perses = {
      after = [ "networking.target" ];
      description = "Perses Daemon";
      preStart = secretsReplacement.script;

      serviceConfig = rec {
        # Hardening
        AmbientCapabilities = mkIf (cfg.port < 1024) [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = if (cfg.port < 1024) then [ "CAP_NET_BIND_SERVICE" ] else [ "" ];
        DynamicUser = true;

        ExecStart = utils.escapeSystemdExecArgs (
          [
            (getExe cfg.package)
            "-config=${configPath}"
            "-web.listen-address=${cfg.listenAddress}:${toString cfg.port}"
          ]
          ++ cfg.extraOptions
        );

        LoadCredential = secretsReplacement.credentials;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "full";
        RemoveIPC = true;
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "perses";
        RuntimeDirectoryMode = "0755";
        StateDirectory = "perses";
        SystemCallArchitectures = "native";
        UMask = "0027";
        User = "perses";
        WorkingDirectory = "%S/${StateDirectory}";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
