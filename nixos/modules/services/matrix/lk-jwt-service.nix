{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.lk-jwt-service;
in
{
  options.services.lk-jwt-service = {
    enable = lib.mkEnableOption "lk-jwt-service";
    package = lib.mkPackageOption pkgs "lk-jwt-service" { };

    keyFile = lib.mkOption {
      description = ''
        Path to a file containing the credential mapping (`<keyname>: <secret>`) to access LiveKit.

        Example:
        `lk-jwt-service: f6lQGaHtM5HfgZjIcec3cOCRfiDqIine4CpZZnqdT5cE`

        For more information, see <https://github.com/element-hq/lk-jwt-service#configuration>.
      '';

      type = lib.types.path;
    };

    livekitUrl = lib.mkOption {
      description = ''
        The public websocket URL for livekit.
        The proto needs to be either  `wss://` (recommended) or `ws://` (insecure).
      '';

      example = "wss://example.com/livekit/sfu";
      type = lib.types.strMatching "^wss?://.*";
    };

    port = lib.mkOption {
      default = 8080;
      description = "Port that lk-jwt-service should listen on.";
      type = lib.types.port;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.lk-jwt-service = {
      after = [ "network-online.target" ];
      description = "Minimal service to issue LiveKit JWTs for MatrixRTC";
      documentation = [ "https://github.com/element-hq/lk-jwt-service" ];

      environment = {
        LIVEKIT_JWT_BIND = ":${toString cfg.port}";
        LIVEKIT_KEY_FILE = "/run/credentials/lk-jwt-service.service/livekit-secrets";
        LIVEKIT_URL = cfg.livekitUrl;
      };

      serviceConfig = {
        DynamicUser = true;
        ExecStart = lib.getExe cfg.package;
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

  meta.maintainers = [ lib.maintainers.quadradical ];
}
