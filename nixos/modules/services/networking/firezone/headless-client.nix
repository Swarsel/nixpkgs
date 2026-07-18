{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    boolToString
    getExe
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;

  cfg = config.services.firezone.headless-client;
in
{
  options = {
    services.firezone.headless-client = {
      enable = mkEnableOption "the firezone headless client";
      package = mkPackageOption pkgs "firezone-headless-client" { };

      apiUrl = mkOption {
        description = ''
          The URL of your firezone server's API. This should be the same
          as your server's setting for {option}`services.firezone.server.settings.api.externalUrl`,
          but with `wss://` instead of `https://`.
        '';

        example = "wss://firezone.example.com/api/";
        type = types.strMatching "^wss://.+/$";
      };

      enableTelemetry = mkEnableOption "telemetry";

      logLevel = mkOption {
        default = "info";

        description = ''
          The log level for the firezone application. See
          [RUST_LOG](https://docs.rs/env_logger/latest/env_logger/#enabling-logging)
          for the format.
        '';

        type = types.str;
      };

      name = mkOption {
        description = "The name of this client as shown in firezone";
        type = types.str;
      };

      tokenFile = mkOption {
        description = ''
          A file containing the firezone client token. Do not use a nix-store path here
          as it will make the token publicly readable!

          This file will be passed via systemd credentials, it should only be accessible
          by the root user.
        '';

        example = "/run/secrets/firezone-client-token";
        type = types.path;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.firezone-headless-client = {
      after = [ "network.target" ];
      description = "headless client service for the Firezone zero-trust access platform";

      environment = {
        FIREZONE_API_URL = cfg.apiUrl;
        FIREZONE_NAME = cfg.name;
        FIREZONE_NO_TELEMETRY = boolToString (!cfg.enableTelemetry);
        FIREZONE_TOKEN_PATH = "%d/firezone-token";
        LOG_DIR = "%L/dev.firezone.client";
        RUST_LOG = cfg.logLevel;
      };

      path = [ pkgs.util-linux ];

      script = ''
        # If FIREZONE_ID is not given by the user, use a persisted (or newly generated) uuid.
        if [[ -z "''${FIREZONE_ID:-}" ]]; then
          if [[ ! -e client_id ]]; then
            uuidgen -r > client_id
          fi
          export FIREZONE_ID=$(< client_id)
        fi

        exec ${getExe cfg.package}
      '';

      serviceConfig = {
        AmbientCapabilities = [ "CAP_NET_ADMIN" ];
        CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
        DeviceAllow = "/dev/net/tun";
        LoadCredential = [ "firezone-token:${cfg.tokenFile}" ];
        LockPersonality = true;
        LogsDirectory = "dev.firezone.client";
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = false;
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
        Restart = "on-failure";
        RestartSec = 10;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        # Hardcoded values in the client :(
        RuntimeDirectory = "dev.firezone.client";
        StateDirectory = "dev.firezone.client";
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
        Type = "exec";
        UMask = "077";
        WorkingDirectory = "/var/lib/dev.firezone.client";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    oddlama
    patrickdag
  ];
}
