{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.unbound;
  inherit (lib)
    mkOption
    types
    mkRemovedOptionModule
    optionalAttrs
    optionalString
    mkMerge
    mkIf
    ;
in
{
  imports = [
    (mkRemovedOptionModule [
      "controlInterface"
    ] "This option was removed, use the `unbound.host` option instead.")
    (mkRemovedOptionModule [
      "fetchType"
    ] "This option was removed, use the `unbound.host` option instead.")
    {
      options.assertions = options.assertions;
      options.warnings = options.warnings;
    }
  ];

  extraOpts = {
    telemetryPath = mkOption {
      default = "/metrics";

      description = ''
        Path under which to expose metrics.
      '';

      type = types.str;
    };

    unbound = {
      ca = mkOption {
        default = "/var/lib/unbound/unbound_server.pem";

        description = ''
          Path to the Unbound server certificate authority
        '';

        example = null;
        type = types.nullOr types.path;
      };

      certificate = mkOption {
        default = "/var/lib/unbound/unbound_control.pem";

        description = ''
          Path to the Unbound control socket certificate
        '';

        example = null;
        type = types.nullOr types.path;
      };

      host = mkOption {
        default = "tcp://127.0.0.1:8953";

        description = ''
          Path to the unbound control socket. Supports unix domain sockets, as well as the TCP interface.
        '';

        example = "unix:///run/unbound/unbound.socket";
        type = types.str;
      };

      key = mkOption {
        default = "/var/lib/unbound/unbound_control.key";

        description = ''
          Path to the Unbound control socket key.
        '';

        example = null;
        type = types.nullOr types.path;
      };
    };
  };

  port = 9167;

  serviceOpts = mkMerge (
    [
      {
        serviceConfig = {
          ExecStart = ''
            ${pkgs.prometheus-unbound-exporter}/bin/unbound_exporter \
              --unbound.host "${cfg.unbound.host}" \
              --web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
              --web.telemetry-path ${cfg.telemetryPath} \
              ${optionalString (cfg.unbound.ca != null) "--unbound.ca ${cfg.unbound.ca}"} \
              ${optionalString (cfg.unbound.certificate != null) "--unbound.cert ${cfg.unbound.certificate}"} \
              ${optionalString (cfg.unbound.key != null) "--unbound.key ${cfg.unbound.key}"} \
              ${toString cfg.extraFlags}
          '';

          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];

          User = "unbound"; # to access the unbound_control.key
        }
        // optionalAttrs (!config.services.unbound.enable) {
          DynamicUser = true;
        };
      }
    ]
    ++ [
      (mkIf config.services.unbound.enable {
        after = [ "unbound.service" ];
        requires = [ "unbound.service" ];
      })
    ]
  );
}
