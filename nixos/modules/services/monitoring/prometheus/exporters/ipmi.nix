{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  logPrefix = "services.prometheus.exporter.ipmi";
  cfg = config.services.prometheus.exporters.ipmi;
  inherit (lib)
    mkOption
    types
    concatStringsSep
    optionals
    escapeShellArg
    ;
in
{
  extraOpts = {
    configFile = mkOption {
      default = null;

      description = ''
        Path to configuration file.
      '';

      type = types.nullOr types.path;
    };

    webConfigFile = mkOption {
      default = null;

      description = ''
        Path to configuration file that can enable TLS or authentication.
      '';

      type = types.nullOr types.path;
    };
  };

  port = 9290;

  serviceOpts.serviceConfig = {
    ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";

    ExecStart =
      with cfg;
      concatStringsSep " " (
        [
          "${pkgs.prometheus-ipmi-exporter}/bin/ipmi_exporter"
          "--web.listen-address ${listenAddress}:${toString port}"
        ]
        ++ optionals (cfg.webConfigFile != null) [
          "--web.config.file ${escapeShellArg cfg.webConfigFile}"
        ]
        ++ optionals (cfg.configFile != null) [
          "--config.file ${escapeShellArg cfg.configFile}"
        ]
        ++ extraFlags
      );

    RestrictAddressFamilies = [
      "AF_INET"
      "AF_INET6"
      "AF_UNIX"
    ];
  };
}
