{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.gs1200-exporter;
in
{
  options.services.gs1200-exporter = {
    enable = lib.mkEnableOption "gs1200-exporter";

    address = lib.mkOption {
      description = "IP address or hostname of the GS1200 switch.";
      example = "192.168.1.3";
      type = lib.types.str;
    };

    debug = lib.mkOption {
      default = false;
      description = "Enable debug logging. Logs are accessible via journalctl -u gs1200-exporter.";
      type = lib.types.bool;
    };

    json = lib.mkOption {
      default = false;
      description = "Output logs in JSON format. Logs are accessible via journalctl -u gs1200-exporter.";
      type = lib.types.bool;
    };

    passwordFile = lib.mkOption {
      default = null;

      description = ''
        Path to a file containing the password to log in to the GS1200 web interface.
        This is the recommended option as it avoids storing the password in the Nix store.
        Compatible with sops-nix and agenix.
      '';

      example = "/run/secrets/gs1200-password";
      type = lib.types.nullOr lib.types.path;
    };

    port = lib.mkOption {
      default = 9934;
      description = "Port on which to expose Prometheus metrics.";
      type = lib.types.port;
    };

    verbose = lib.mkOption {
      default = false;
      description = "Enable verbose logging. Logs are accessible via journalctl -u gs1200-exporter.";
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services.gs1200-exporter = {
      after = [ "network.target" ];
      description = "Prometheus exporter for Zyxel GS1200 switches";

      script =
        let
          args = lib.concatStringsSep " " (
            [
              "--address ${cfg.address}"
              "--port ${toString cfg.port}"
            ]
            ++ lib.optional cfg.debug "--debug"
            ++ lib.optional cfg.verbose "--verbose"
            ++ lib.optional cfg.json "--json"
          );
        in
        ''
          export GS1200_PASSWORD=$(cat ${cfg.passwordFile})
          exec ${lib.getExe pkgs.gs1200-exporter} ${args}
        '';

      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = true;
        # Hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        Restart = "always";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ DerGrumpf ];
}
