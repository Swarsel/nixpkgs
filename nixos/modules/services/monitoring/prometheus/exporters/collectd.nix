{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.collectd;
  inherit (lib)
    mkOption
    mkEnableOption
    types
    optionalString
    concatStringsSep
    escapeShellArg
    ;
in
{
  extraOpts = {
    collectdBinary = {
      enable = mkEnableOption "collectd binary protocol receiver";

      authFile = mkOption {
        default = null;
        description = "File mapping user names to pre-shared keys (passwords).";
        type = types.nullOr types.path;
      };

      listenAddress = mkOption {
        default = "0.0.0.0";

        description = ''
          Address to listen on for binary network packets.
        '';

        type = types.str;
      };

      port = mkOption {
        default = 25826;
        description = "Network address on which to accept collectd binary network packets.";
        type = types.port;
      };

      securityLevel = mkOption {
        default = "None";

        description = ''
          Minimum required security level for accepted packets.
        '';

        type = types.enum [
          "None"
          "Sign"
          "Encrypt"
        ];
      };
    };

    logFormat = mkOption {
      default = "logfmt";

      description = ''
        Set the log format.
      '';

      example = "json";

      type = types.enum [
        "logfmt"
        "json"
      ];
    };

    logLevel = mkOption {
      default = "info";

      description = ''
        Only log messages with the given severity or above.
      '';

      type = types.enum [
        "debug"
        "info"
        "warn"
        "error"
        "fatal"
      ];
    };
  };

  port = 9103;

  serviceOpts =
    let
      collectSettingsArgs = optionalString (cfg.collectdBinary.enable) ''
        --collectd.listen-address ${cfg.collectdBinary.listenAddress}:${toString cfg.collectdBinary.port} \
        --collectd.security-level ${cfg.collectdBinary.securityLevel}
      '';
    in
    {
      serviceConfig = {
        ExecStart = ''
          ${pkgs.prometheus-collectd-exporter}/bin/collectd_exporter \
            --log.format ${escapeShellArg cfg.logFormat} \
            --log.level ${cfg.logLevel} \
            --web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
            ${collectSettingsArgs} \
            ${concatStringsSep " \\\n  " cfg.extraFlags}
        '';
      };
    };
}
