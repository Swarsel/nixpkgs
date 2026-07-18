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

  cfg = config.services.firezone.gateway;
in
{
  options = {
    services.firezone.gateway = {
      enable = mkOption {
        default = false;

        description = ''
          Whether to enable the firezone gateway.

          You have to manually masquerade and forward traffic from the
          tun-firezone interface to your resource! Refer to the
          [upstream setup script](https://github.com/firezone/firezone/blob/8c7c0a9e8e33ae790aeb75fdb5a15432c2870b79/scripts/gateway-systemd-install.sh#L154-L168)
          for a list of iptable commands.

          See the firezone nixos test in this repository for an nftables based example.
        '';

        example = true;
        type = lib.types.bool;
      };

      package = mkPackageOption pkgs "firezone-gateway" { };

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
        description = "The name of this gateway as shown in firezone";
        type = types.str;
      };

      tokenFile = mkOption {
        description = ''
          A file containing the firezone gateway token. Do not use a nix-store path here
          as it will make the token publicly readable!

          This file will be passed via systemd credentials, it should only be accessible
          by the root user.
        '';

        example = "/run/secrets/firezone-gateway-token";
        type = types.path;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.firezone-gateway = {
      after = [ "network.target" ];
      description = "Gateway service for the Firezone zero-trust access platform";

      environment = {
        FIREZONE_API_URL = cfg.apiUrl;
        FIREZONE_NAME = cfg.name;
        FIREZONE_NO_TELEMETRY = boolToString (!cfg.enableTelemetry);
        RUST_LOG = cfg.logLevel;
      };

      path = [ pkgs.util-linux ];

      script = ''
        # If FIREZONE_ID is not given by the user, use a persisted (or newly generated) uuid.
        if [[ -z "''${FIREZONE_ID:-}" ]]; then
          if [[ ! -e gateway_id ]]; then
            uuidgen -r > gateway_id
          fi
          export FIREZONE_ID=$(< gateway_id)
        fi

        export FIREZONE_TOKEN=$(< "$CREDENTIALS_DIRECTORY/firezone-token")
        exec ${getExe cfg.package}
      '';

      serviceConfig = {
        AmbientCapabilities = [ "CAP_NET_ADMIN" ];
        CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
        DeviceAllow = "/dev/net/tun";
        DynamicUser = true;
        LoadCredential = [ "firezone-token:${cfg.tokenFile}" ];
        LockPersonality = true;
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
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "firezone-gateway";
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
        Type = "exec";
        UMask = "077";
        User = "firezone-gateway";
        WorkingDirectory = "/var/lib/firezone-gateway";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    oddlama
    patrickdag
  ];
}
