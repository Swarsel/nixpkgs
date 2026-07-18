{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.nezha;

  # nezha uses yaml as the configuration file format.
  # Since we need to use jq to update the content, so here we generate json
  settingsFormat = pkgs.formats.json { };
  configFile = settingsFormat.generate "config.json" cfg.settings;
in
{
  options = {
    services.nezha = {
      enable = lib.mkEnableOption "Nezha Monitoring";
      package = lib.mkPackageOption pkgs "nezha" { };

      agentSecretFile = lib.mkOption {
        default = null;

        description = ''
          Path to the file containing the secret used by agents to connect.
        '';

        type = lib.types.path;
      };

      debug = lib.mkEnableOption "verbose log";

      extraThemes = lib.mkOption {
        default = [ ];

        description = ''
          A list of additional themes.
        '';

        example = lib.literalExpression "[ pkgs.nezha-theme-nazhua ]";
        type = lib.types.listOf lib.types.package;
      };

      jwtSecretFile = lib.mkOption {
        default = null;

        description = ''
          Path to the file containing the secret to sign web requests using JSON Web Tokens.
        '';

        type = lib.types.path;
      };

      mutableConfig = lib.mkOption {
        default = true;

        description = ''
          Whether the config.yaml is writable by Nezha.

          If this option is disabled, changes on the web interface won't
          be possible. If an config.yaml is present, it will be overwritten.
        '';

        type = lib.types.bool;
      };

      settings = lib.mkOption {
        description = ''
          Generate to {file}`config.yaml` as a Nix attribute set.
          Check the [guide](https://nezha.wiki/en_US/guide/dashboard.html)
          for possible options.
        '';

        type = lib.types.submodule {
          options = {
            listenhost = lib.mkOption {
              default = "127.0.0.1";

              description = ''
                Host on which the nezha web interface and grpc should listen.
              '';

              type = lib.types.str;
            };

            listenport = lib.mkOption {
              default = 8008;

              description = ''
                Port on which the nezha web interface and grpc should listen.
              '';

              type = lib.types.port;
            };

          };

          freeformType = settingsFormat.type;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.nezha.settings.debug = cfg.debug;

    systemd.services.nezha = {
      enableStrictShellChecks = true;

      preStart = ''
        cp "${configFile}" "''${RUNTIME_DIRECTORY}"/new
        ${lib.getExe pkgs.jq} \
            --arg jwt_secret "$(<"''${CREDENTIALS_DIRECTORY}"/jwt-secret)" \
            --arg agent_secret "$(<"''${CREDENTIALS_DIRECTORY}"/agent-secret)" \
            '. + { jwtsecretkey: $jwt_secret, agentsecretkey: $agent_secret }' \
            < "''${RUNTIME_DIRECTORY}"/new > "''${RUNTIME_DIRECTORY}"/tmp
        mv "''${RUNTIME_DIRECTORY}"/tmp "''${RUNTIME_DIRECTORY}"/new

        ${lib.optionalString cfg.mutableConfig ''
          [ -e "''${CONFIGURATION_DIRECTORY}"/config.yaml ] && \
            ${lib.getExe pkgs.yj} < "''${CONFIGURATION_DIRECTORY}"/config.yaml > "''${RUNTIME_DIRECTORY}"/old && \
            ${lib.getExe pkgs.jq} -s '.[0] * .[1]' \
              "''${RUNTIME_DIRECTORY}"/old "''${RUNTIME_DIRECTORY}"/new > "''${RUNTIME_DIRECTORY}"/tmp
          [ -e "''${RUNTIME_DIRECTORY}"/old ] && rm "''${RUNTIME_DIRECTORY}"/old
          [ -e "''${RUNTIME_DIRECTORY}"/tmp ] && mv "''${RUNTIME_DIRECTORY}"/tmp "''${RUNTIME_DIRECTORY}"/new
        ''}
        mv "''${RUNTIME_DIRECTORY}"/new  "''${CONFIGURATION_DIRECTORY}"/config.yaml
      '';

      serviceConfig = {
        AmbientCapabilities = lib.optionalString (cfg.settings.listenport < 1024) "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = lib.optionalString (cfg.settings.listenport < 1024) "CAP_NET_BIND_SERVICE";
        ConfigurationDirectory = "nezha";
        DynamicUser = true;

        ExecStart =
          let
            package = cfg.package.override { withThemes = cfg.extraThemes; };
          in
          ''${lib.getExe package} -c "''${CONFIGURATION_DIRECTORY}"/config.yaml -db "''${STATE_DIRECTORY}"/sqlite.db'';

        LoadCredential = [
          "jwt-secret:${cfg.jwtSecretFile}"
          "agent-secret:${cfg.agentSecretFile}"
        ];

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = "yes";
        PrivateTmp = true;
        PrivateUsers = cfg.settings.listenport >= 1024; # incompatible with CAP_NET_BIND_SERVICE
        # Hardening
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

        ReadWritePaths = [
          "/var/lib/nezha"
          "/etc/nezha"
        ];

        RemoveIPC = true;
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "nezha";
        StateDirectory = "nezha";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ]
        ++ lib.optional (cfg.settings ? tsdb) "mincore";

        UMask = "0066";
        WorkingDirectory = "/var/lib/nezha";
      };

      startLimitBurst = 3;
      startLimitIntervalSec = 10;
      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
