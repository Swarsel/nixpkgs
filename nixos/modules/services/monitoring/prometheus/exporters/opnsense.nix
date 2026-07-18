{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.prometheus.exporters.opnsense;
  inherit (lib)
    mkOption
    types
    optionalString
    concatStringsSep
    concatMapStringsSep
    ;
in
{
  extraOpts = {
    apiKeyFile = mkOption {
      description = ''
        File containing the api key.
      '';

      type = types.nullOr types.path;
    };

    apiSecretFile = mkOption {
      description = ''
        File containing the api secret.
      '';

      type = types.nullOr types.path;
    };

    disabledExporter = mkOption {
      default = [ ];

      description = ''
        Collectors to enable or disable.
        All collectors are enabled by default.
      '';

      example = [ "disable-openvpn" ];
      type = types.listOf types.str;
    };

    enabledExporter = mkOption {
      default = [ ];

      description = ''
        Collectors to enable or disable.
        All collectors are enabled by default.
      '';

      example = [ "disable-openvpn" ];
      type = types.listOf types.str;
    };

    group = mkOption {
      default = "opnsense";

      description = ''
        Group under which the opnsense exporter shall be run.
      '';

      type = types.str;
    };

    opnsenseServerAddress = mkOption {
      default = "192.168.1.1";

      description = ''
        Opnsense IP address of the opnsense appliance.
        Defaults to 192.168.1.1
      '';

      example = "192.168.100.254";
      type = types.str;
    };

    opnsenseServerProtocol = mkOption {
      default = "https";

      description = ''
        Opnsense metrics scraper protocol to use.
        Defaults to https.
      '';

      example = "http";

      type = types.enum [
        "http"
        "https"
      ];
    };

    user = mkOption {
      default = "opnsense";

      description = ''
        User name under which the opensense exporter shall be run.
      '';

      type = types.str;
    };
  };

  port = 9144;

  serviceOpts = {
    serviceConfig = {
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];

      ExecStart = ''
        ${lib.getExe pkgs.prometheus-opnsense-exporter} \
          ${concatMapStringsSep " " (x: "--exporter." + x) cfg.enabledExporter} \
          ${concatMapStringsSep " " (x: "--no-exporter." + x) cfg.disabledExporter} \
          --opnsense.address ${cfg.opnsenseServerAddress} \
          --opnsense.protocol ${cfg.opnsenseServerProtocol} \
          --web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
          ${concatStringsSep " " cfg.extraFlags}
      '';

      LoadCredential = [
        "${optionalString (cfg.apiKeyFile != null) "opnsense.api-key=${cfg.apiKeyFile}"}"
        "${optionalString (cfg.apiSecretFile != null) "opnsense.api-secret=${cfg.apiSecretFile}"}"
      ];

      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      ProtectClock = true;
      ProtectSystem = "strict";
      Restart = "on-failure";

      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];

      RestrictNamespaces = true;
      RestrictRealtime = true;
    };
  };
}
