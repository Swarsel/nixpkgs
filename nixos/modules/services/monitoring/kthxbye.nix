{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.kthxbye;
in

{
  options.services.kthxbye = {
    enable = lib.mkEnableOption "kthxbye alert acknowledgement management daemon";
    package = lib.mkPackageOption pkgs "kthxbye" { };

    alertmanager = {
      timeout = lib.mkOption {
        default = "1m0s";

        description = ''
          Alertmanager request timeout duration in the [time.Duration](https://pkg.go.dev/time#ParseDuration) format.
        '';

        example = "30s";
        type = lib.types.str;
      };

      uri = lib.mkOption {
        default = "http://localhost:9093";

        description = ''
          Alertmanager URI to use.
        '';

        example = "https://alertmanager.example.com";
        type = lib.types.str;
      };
    };

    extendBy = lib.mkOption {
      default = "15m0s";

      description = ''
        Extend silences by adding DURATION seconds.

        DURATION should be provided in the [time.Duration](https://pkg.go.dev/time#ParseDuration) format.
      '';

      example = "6h0m0s";
      type = lib.types.str;
    };

    extendIfExpiringIn = lib.mkOption {
      default = "5m0s";

      description = ''
        Extend silences that are about to expire in the next DURATION seconds.

        DURATION should be provided in the [time.Duration](https://pkg.go.dev/time#ParseDuration) format.
      '';

      example = "1m0s";
      type = lib.types.str;
    };

    extendWithPrefix = lib.mkOption {
      default = "ACK!";

      description = ''
        Extend silences with comment starting with PREFIX string.
      '';

      example = "!perma-silence";
      type = lib.types.str;
    };

    extraOptions = lib.mkOption {
      default = [ ];

      description = ''
        Extra command line options.

        Documentation can be found [here](https://github.com/prymitive/kthxbye/blob/main/README.md).
      '';

      example = lib.literalExpression ''
        [
          "-extend-with-prefix 'ACK!'"
        ];
      '';

      type = with lib.types; listOf str;
    };

    interval = lib.mkOption {
      default = "45s";

      description = ''
        Silence check interval duration in the [time.Duration](https://pkg.go.dev/time#ParseDuration) format.
      '';

      example = "30s";
      type = lib.types.str;
    };

    listenAddress = lib.mkOption {
      default = "0.0.0.0";

      description = ''
        The address to listen on for HTTP requests.
      '';

      example = "127.0.0.1";
      type = lib.types.str;
    };

    logJSON = lib.mkOption {
      default = false;

      description = ''
        Format logged messages as JSON.
      '';

      type = lib.types.bool;
    };

    maxDuration = lib.mkOption {
      default = null;

      description = ''
        Maximum duration of a silence, it won't be extended anymore after reaching it.

        Duration should be provided in the [time.Duration](https://pkg.go.dev/time#ParseDuration) format.
      '';

      example = "30d";
      type = with lib.types; nullOr str;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Whether to open ports in the firewall needed for the daemon to function.
      '';

      type = lib.types.bool;
    };

    port = lib.mkOption {
      default = 8080;

      description = ''
        The port to listen on for HTTP requests.
      '';

      type = lib.types.port;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.kthxbye = {
      description = "kthxbye Alertmanager ack management daemon";

      script = ''
        ${cfg.package}/bin/kthxbye \
          -alertmanager.timeout ${cfg.alertmanager.timeout} \
          -alertmanager.uri ${cfg.alertmanager.uri} \
          -extend-by ${cfg.extendBy} \
          -extend-if-expiring-in ${cfg.extendIfExpiringIn} \
          -extend-with-prefix ${cfg.extendWithPrefix} \
          -interval ${cfg.interval} \
          -listen ${cfg.listenAddress}:${toString cfg.port} \
          ${lib.optionalString cfg.logJSON "-log-json"} \
          ${lib.optionalString (cfg.maxDuration != null) "-max-duration ${cfg.maxDuration}"} \
          ${lib.concatStringsSep " " cfg.extraOptions}
      '';

      serviceConfig = {
        DynamicUser = true;
        Restart = "on-failure";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
