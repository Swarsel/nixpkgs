{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.livekit;
  format = pkgs.formats.json { };
  settings = lib.filterAttrsRecursive (_: v: v != null) cfg.settings;

  isLocallyDistributed = config.services.livekit.ingress.enable;
in
{
  options.services.livekit = {
    enable = lib.mkEnableOption "the livekit server";
    package = lib.mkPackageOption pkgs "livekit" { };

    keyFile = lib.mkOption {
      description = ''
        LiveKit key file holding one or multiple application secrets. Use `livekit-server generate-keys` to generate a random key name and secret.

        The file should have the format `<keyname>: <secret>`.
        Example:
        `lk-jwt-service: f6lQGaHtM5HfgZjIcec3cOCRfiDqIine4CpZZnqdT5cE`

        Individual key/secret pairs need to be passed to clients to connect to this instance.
      '';

      type = lib.types.path;
    };

    openFirewall = lib.mkOption {
      default = false;
      description = "Opens port range for LiveKit on the firewall.";
      type = lib.types.bool;
    };

    redis = {
      createLocally = lib.mkOption {
        default = isLocallyDistributed;
        defaultText = "true if any other Livekit component is enabled locally else false";
        description = "Whether to set up a local redis instance.";
        type = lib.types.bool;
      };

      host = lib.mkOption {
        default = if cfg.redis.createLocally then "127.0.0.1" else null;
        defaultText = "127.0.0.1 if config.services.livekit.redis.createLocally else null";

        description = ''
          Address to bind local redis instance to.
        '';

        type = with lib.types; nullOr str;
      };

      port = lib.mkOption {
        default = null;

        description = ''
          Port to bind local redis instance to.
        '';

        type = with lib.types; nullOr port;
      };
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        LiveKit configuration file expressed in nix.

        For an example configuration, see <https://docs.livekit.io/home/self-hosting/deployment/#configuration>.
        For all possible values, see <https://github.com/livekit/livekit/blob/master/config-sample.yaml>.
      '';

      type = lib.types.submodule {
        options = {
          port = lib.mkOption {
            default = 7880;
            description = "Main TCP port for RoomService and RTC endpoint.";
            type = lib.types.port;
          };

          redis = {
            address = lib.mkOption {
              default = if isLocallyDistributed then "${cfg.redis.host}:${toString cfg.redis.port}" else null;
              defaultText = lib.literalExpression "Local Redis host/port when a local ingress component is enabled else null";
              description = "Host and port used to connect to a redis instance.";
              example = "redis.example.com:6379";
              type = with lib.types; nullOr str;
            };
          };

          rtc = {
            port_range_end = lib.mkOption {
              default = 51000;
              description = "End of UDP port range for WebRTC";
              type = lib.types.port;
            };

            port_range_start = lib.mkOption {
              default = 50000;
              description = "Start of UDP port range for WebRTC";
              type = lib.types.port;
            };

            use_external_ip = lib.mkOption {
              default = false;

              description = ''
                When set to true, attempts to discover the host's public IP via STUN.
                This is useful for cloud environments such as AWS & Google where hosts have an internal IP that maps to an external one.
              '';

              type = lib.types.bool;
            };
          };
        };

        freeformType = format.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.redis.createLocally -> cfg.redis.port != null;

        message = ''
          When `services.livekit.redis.createLocally` is enabled `services.livekit.redis.port` must be configured.
        '';
      }
    ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [
        cfg.settings.port
      ];

      allowedUDPPortRanges = [
        {
          from = cfg.settings.rtc.port_range_start;
          to = cfg.settings.rtc.port_range_end;
        }
      ];
    };

    # Provision a redis instance, when livekit-ingress (or later livekit-egress) are enabled on the same host
    services.redis.servers.livekit = lib.mkIf cfg.redis.createLocally {
      enable = true;
      bind = cfg.redis.host;
      port = cfg.redis.port;
    };

    systemd.services.livekit = {
      after = [ "network-online.target" ];
      description = "LiveKit SFU server";
      documentation = [ "https://docs.livekit.io" ];

      serviceConfig = {
        DynamicUser = true;

        ExecStart = utils.escapeSystemdExecArgs [
          (lib.getExe cfg.package)
          "--config=${format.generate "livekit.json" settings}"
          "--key-file=/run/credentials/livekit.service/livekit-secrets"
        ];

        LoadCredential = [ "livekit-secrets:${cfg.keyFile}" ];
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        Restart = "on-failure";
        RestartSec = 5;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "077";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ quadradical ];
}
