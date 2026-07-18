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
    isBool
    maintainers
    mapAttrs
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optionalAttrs
    optionals
    types
    ;

  cfg = config.services.pairdrop;

  json = pkgs.formats.json { };
in
{
  options.services.pairdrop = {
    enable = mkEnableOption "pairdrop";
    package = mkPackageOption pkgs "pairdrop" { };

    environment = mkOption {
      default = { };

      description = ''
        Additional configuration (environment variables) for PairDrop, see
        <https://github.com/schlagmichdoch/PairDrop/blob/master/docs/host-your-own.md#environment-variables>
        for supported values.
      '';

      example = {
        BLUESKY_BUTTON_ACTIVE = false;
        CUSTOM_BUTTON_ACTIVE = false;
        DEBUG_MODE = true;
        DONATION_BUTTON_ACTIVE = false;
        IPV6_LOCALIZE = 4;
        MASTODON_BUTTON_ACTIVE = false;
        PRIVACYPOLICY_BUTTON_ACTIVE = false;
        RATE_LIMIT = 1;
        RTC_CONFIG = "/etc/pairdrop/rtc-config.json";
        SIGNALING_SERVER = "pairdrop.net";
        TWITTER_BUTTON_ACTIVE = false;
        WS_FALLBACK = true;
      };

      type = types.submodule {
        options = { };

        freeformType =
          with types;
          attrsOf (oneOf [
            bool
            int
            str
          ]);
      };
    };

    port = mkOption {
      default = 3000;
      description = "The port to listen on.";
      example = 3010;
      type = types.port;
    };

    rtcConfig = mkOption {
      default = null;

      description = ''
        Configuration for STUN/TURN servers.
        This is converted to JSON and written into a file automatically.
        If you want to provide a file path instead, set `RTC_CONFIG` in {option}`services.pairdrop.environment`.
      '';

      example = {
        iceServers = [
          {
            urls = "stun:stun.example.com:19302";
          }
        ];

        sdpSemantics = "unified-plan";
      };

      type = json.type;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.pairdrop =
      let
        environment = {
          PORT = toString cfg.port;
        }
        // (optionalAttrs (cfg.rtcConfig != null) {
          RTC_CONFIG = json.generate "rtc-config.json" cfg.rtcConfig;
        })
        // (mapAttrs (_: v: if isBool v then boolToString v else toString v) cfg.environment);
      in
      {
        inherit environment;
        after = [ "network.target" ];
        description = "PairDrop: Transfer Files Cross-Platform";

        serviceConfig = {
          # Hardening
          CapabilityBoundingSet = "";
          DynamicUser = true;
          ExecStart = getExe cfg.package;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          Restart = "on-failure";
          RestartSec = 3;

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          Type = "simple";
        };

        wantedBy = [ "multi-user.target" ];
      };

    warnings = optionals (cfg.rtcConfig != null && cfg.environment ? RTC_CONFIG) [
      "Both services.pairdrop.rtcConfig and services.pairdrop.environment.RTC_CONFIG are set. The environment variable will take precedence."
    ];
  };

  meta.maintainers = with maintainers; [ diogotcorreia ];
}
