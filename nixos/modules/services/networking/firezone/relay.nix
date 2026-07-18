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

  cfg = config.services.firezone.relay;
in
{
  options = {
    services.firezone.relay = {
      enable = mkEnableOption "the firezone relay server";
      package = mkPackageOption pkgs "firezone-relay" { };

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

      highestPort = mkOption {
        default = 65535;
        description = "The highest port to use in TURN allocation";
        type = types.port;
      };

      logLevel = mkOption {
        default = "info";

        description = ''
          The log level for the firezone application. See
          [RUST_LOG](https://docs.rs/env_logger/latest/env_logger/#enabling-logging)
          for the format.
        '';

        type = types.str;
      };

      lowestPort = mkOption {
        default = 49152;
        description = "The lowest port to use in TURN allocation";
        type = types.port;
      };

      name = mkOption {
        description = "The name of this gateway as shown in firezone";
        example = "My relay";
        type = types.str;
      };

      openFirewall = mkOption {
        default = true;
        description = "Opens up the main STUN port and the TURN allocation range.";
        type = types.bool;
      };

      port = mkOption {
        default = 3478;
        description = "The port to listen on for STUN messages";
        type = types.port;
      };

      publicIpv4 = mkOption {
        default = null;
        description = "The public ipv4 address of this relay";
        type = types.nullOr types.str;
      };

      publicIpv6 = mkOption {
        default = null;
        description = "The public ipv6 address of this relay";
        type = types.nullOr types.str;
      };

      tokenFile = mkOption {
        description = ''
          A file containing the firezone relay token. Do not use a nix-store path here
          as it will make the token publicly readable!

          This file will be passed via systemd credentials, it should only be accessible
          by the root user.
        '';

        example = "/run/secrets/firezone-relay-token";
        type = types.path;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.publicIpv4 != null || cfg.publicIpv6 != null;
        message = "At least one of `services.firezone.relay.publicIpv4` and `services.firezone.relay.publicIpv6` must be set";
      }
    ];

    networking.firewall.allowedUDPPortRanges = mkIf cfg.openFirewall [
      {
        from = cfg.lowestPort;
        to = cfg.highestPort;
      }
    ];

    networking.firewall.allowedUDPPorts = mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.firezone-relay = {
      after = [ "network.target" ];
      description = "relay service for the Firezone zero-trust access platform";

      environment = {
        FIREZONE_API_URL = cfg.apiUrl;
        FIREZONE_NAME = cfg.name;
        FIREZONE_TELEMETRY = boolToString cfg.enableTelemetry;
        HIGHEST_PORT = toString cfg.highestPort;
        LISTEN_PORT = toString cfg.port;
        LOG_FORMAT = "human";
        LOWEST_PORT = toString cfg.lowestPort;
        PUBLIC_IP4_ADDR = cfg.publicIpv4;
        PUBLIC_IP6_ADDR = cfg.publicIpv6;
        RUST_LOG = cfg.logLevel;
      };

      path = [ pkgs.util-linux ];

      script = ''
        # If FIREZONE_ID is not given by the user, use a persisted (or newly generated) uuid.
        if [[ -z "''${FIREZONE_ID:-}" ]]; then
          if [[ ! -e relay_id ]]; then
            uuidgen -r > relay_id
          fi
          export FIREZONE_ID=$(< relay_id)
        fi

        export FIREZONE_TOKEN=$(< "$CREDENTIALS_DIRECTORY/firezone-token")
        exec ${getExe cfg.package}
      '';

      serviceConfig = {
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
        StateDirectory = "firezone-relay";
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
        Type = "exec";
        UMask = "077";
        User = "firezone-relay";
        WorkingDirectory = "/var/lib/firezone-relay";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    oddlama
    patrickdag
  ];
}
