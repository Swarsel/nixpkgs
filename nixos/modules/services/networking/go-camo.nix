{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.go-camo;
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    optionalString
    ;
in
{
  options.services.go-camo = {
    enable = mkEnableOption "go-camo service";

    extraOptions = mkOption {
      default = [ ];
      description = "Extra options passed to the go-camo command.";
      type = with types; listOf str;
    };

    keyFile = mkOption {
      default = null;

      description = ''
        A file containing the HMAC key to use for signing URLs.
        The file can contain any string. Can be generated using "openssl rand -base64 18 > the_file".
      '';

      type = types.path;
    };

    listen = mkOption {
      apply = v: optionalString (v != null) "--listen=${v}";
      default = null;
      description = "Address:Port to bind to for HTTP (default: 0.0.0.0:8080).";
      type = types.nullOr types.str;
    };

    sslCert = mkOption {
      apply = v: optionalString (v != null) "--ssl-cert=${v}";
      default = null;
      description = "Path to TLS certificate.";
      type = types.nullOr types.path;
    };

    sslKey = mkOption {
      apply = v: optionalString (v != null) "--ssl-key=${v}";
      default = null;
      description = "Path to TLS private key.";
      type = types.nullOr types.path;
    };

    sslListen = mkOption {
      apply = v: optionalString (v != null) "--ssl-listen=${v}";
      default = null;
      description = "Address:Port to bind to for HTTPS.";
      type = types.nullOr types.str;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.go-camo = {
      after = [ "network.target" ];
      description = "go-camo service";

      environment = {
        GOCAMO_HMAC_FILE = "%d/hmac";
      };

      script = ''
        GOCAMO_HMAC="$(cat "$GOCAMO_HMAC_FILE")"
        export GOCAMO_HMAC
        exec ${
          lib.escapeShellArgs (
            lib.lists.remove "" (
              [
                "${pkgs.go-camo}/bin/go-camo"
                cfg.listen
                cfg.sslListen
                cfg.sslKey
                cfg.sslCert
              ]
              ++ cfg.extraOptions
            )
          )
        }
      '';

      serviceConfig = {
        DynamicUser = true;
        Group = "gocamo";

        LoadCredential = [
          "hmac:${cfg.keyFile}"
        ];

        NoNewPrivileges = true;
        ProtectSystem = "strict";
        User = "gocamo";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
