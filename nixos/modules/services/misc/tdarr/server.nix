{
  config,
  lib,
  ...
}:

let
  cfg = config.services.tdarr;
  serverDataDir = "${cfg.dataDir}/server";
  serverEnabled = cfg.enable || cfg.server.enable;
in
{
  options.services.tdarr.server = {
    enable = lib.mkEnableOption "Tdarr server";

    package = lib.mkOption {
      default = cfg.package.server;
      defaultText = lib.literalExpression "config.services.tdarr.package.server";
      description = "Package to use for the Tdarr server.";
      type = lib.types.package;
    };

    auth.enable = lib.mkOption {
      default = false;
      description = "Whether to enable authentication for the Tdarr web UI and API.";
      type = lib.types.bool;
    };

    cronPluginUpdate = lib.mkOption {
      default = "";
      description = "Cron expression for automatic plugin updates. Empty string disables.";
      example = "0 2 * * *";
      type = lib.types.str;
    };

    environmentFile = lib.mkOption {
      default = null;

      description = ''
        File containing environment variable overrides for the server,
        in the format accepted by systemd's `EnvironmentFile`.

        Useful for setting secrets such as `authSecretKey` or `seededApiKey`
        without exposing them in the Nix store.

        Example file contents:
        ```
        authSecretKey=your-secret-key
        seededApiKey=tapi_your_api_key_here
        ```
      '';

      example = "/run/secrets/tdarr-server-env";
      type = lib.types.nullOr lib.types.path;
    };

    maxLogSizeMB = lib.mkOption {
      default = 10;
      description = "Maximum log file size in megabytes.";
      type = lib.types.ints.unsigned;
    };

    openFirewall = lib.mkOption {
      default = false;
      description = "Whether to open the firewall for the Tdarr server web UI and API ports.";
      type = lib.types.bool;
    };

    serverBindIP = lib.mkOption {
      default = false;
      description = "Whether to bind to the specific IP in {option}`services.tdarr.server.serverIP`.";
      type = lib.types.bool;
    };

    serverDualStack = lib.mkOption {
      default = false;

      description = ''
        Enable dual-stack (IPv4/IPv6) networking.

        When enabled, the server binds to `::` if IPv6 is available, accepting both
        IPv4 and IPv6 connections. Useful in Kubernetes and other modern networking setups.
      '';

      type = lib.types.bool;
    };

    serverIP = lib.mkOption {
      default = "0.0.0.0";
      description = "IP address the server binds to.";
      type = lib.types.str;
    };

    serverPort = lib.mkOption {
      default = 8266;
      description = "Port for server API communication.";
      type = lib.types.port;
    };

    webUIPort = lib.mkOption {
      default = 8265;
      description = "Port for the Tdarr web UI.";
      type = lib.types.port;
    };
  };

  config = lib.mkIf serverEnabled {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.server.openFirewall [
      cfg.server.serverPort
      cfg.server.webUIPort
    ];

    systemd.services.tdarr-server = {
      after = [ "network.target" ];
      description = "Tdarr Server";

      environment = {
        auth = lib.boolToString cfg.server.auth.enable;
        cronPluginUpdate = cfg.server.cronPluginUpdate;
        maxLogSizeMB = toString cfg.server.maxLogSizeMB;
        openBrowser = "false";
        rootDataPath = serverDataDir;
        serverBindIP = lib.boolToString cfg.server.serverBindIP;
        serverDualStack = lib.boolToString cfg.server.serverDualStack;
        serverIP = cfg.server.serverIP;
        serverPort = toString cfg.server.serverPort;
        webUIPort = toString cfg.server.webUIPort;
      };

      serviceConfig = {
        ExecStart = lib.getExe cfg.server.package;
        Group = cfg.group;
        # Hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ cfg.dataDir ];
        Restart = "on-failure";
        RestartSec = 5;
        Type = "simple";
        User = cfg.user;
        WorkingDirectory = serverDataDir;
      }
      // lib.optionalAttrs (cfg.server.environmentFile != null) {
        EnvironmentFile = cfg.server.environmentFile;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d ${serverDataDir} 0750 ${cfg.user} ${cfg.group} -"
      "d ${serverDataDir}/configs 0750 ${cfg.user} ${cfg.group} -"
    ];
  };
}
