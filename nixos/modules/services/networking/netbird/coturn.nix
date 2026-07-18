{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    getExe
    literalExpression
    mkAfter
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    optionalAttrs
    optionalString
    ;

  inherit (lib.types)
    bool
    listOf
    nullOr
    path
    port
    str
    ;

  cfg = config.services.netbird.server.coturn;
in

{
  options.services.netbird.server.coturn = {
    enable = mkEnableOption "a Coturn server for Netbird, will also open the firewall on the configured range";

    domain = mkOption {
      description = "The domain under which the coturn server runs.";
      type = str;
    };

    openPorts = mkOption {
      default = with config.services.coturn; [
        listening-port
        alt-listening-port
        tls-listening-port
        alt-tls-listening-port
      ];

      defaultText = literalExpression ''
        with config.services.coturn; [
          listening-port
          alt-listening-port
          tls-listening-port
          alt-tls-listening-port
        ];
      '';

      description = ''
        The list of ports used by coturn for listening to open in the firewall.
      '';

      type = listOf port;
    };

    password = mkOption {
      default = null;

      description = ''
        The password of the user used by netbird to connect to the coturn server.
        Be advised this will be world readable in the nix store.
      '';

      type = nullOr str;
    };

    passwordFile = mkOption {
      default = null;

      description = ''
        The path to a file containing the password of the user used by netbird to connect to the coturn server.
      '';

      type = nullOr path;
    };

    useAcmeCertificates = mkOption {
      default = false;

      description = ''
        Whether to use ACME certificates corresponding to the given domain for the server.
      '';

      type = bool;
    };

    user = mkOption {
      default = "netbird";

      description = ''
        The username used by netbird to connect to the coturn server.
      '';

      type = str;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = (cfg.password == null) != (cfg.passwordFile == null);
          message = "Exactly one of `password` or `passwordFile` must be given for the coturn setup.";
        }
      ];

      networking.firewall = {
        allowedTCPPorts = cfg.openPorts;

        allowedUDPPortRanges = with config.services.coturn; [
          {
            from = min-port;
            to = max-port;
          }
        ];

        allowedUDPPorts = cfg.openPorts;
      };

      security.acme.certs = mkIf cfg.useAcmeCertificates {
        ${cfg.domain}.postRun = ''
          systemctl restart coturn.service
        '';
      };

      services.coturn = {
        enable = true;

        extraConfig = ''
          fingerprint
          user=${cfg.user}:${if cfg.password != null then cfg.password else "@password@"}
          no-software-attribute
        '';

        lt-cred-mech = true;
        no-cli = true;
        realm = cfg.domain;
      }
      // (optionalAttrs cfg.useAcmeCertificates {
        cert = "@cert@";
        pkey = "@pkey@";
      });

      systemd.services.coturn =
        let
          dir = config.security.acme.certs.${cfg.domain}.directory;
          preStart' =
            (optionalString (cfg.passwordFile != null) ''
              ${getExe pkgs.replace-secret} @password@ ${cfg.passwordFile} /run/coturn/turnserver.cfg
            '')
            + (optionalString cfg.useAcmeCertificates ''
              ${getExe pkgs.replace-secret} @cert@ <(echo -n "$CREDENTIALS_DIRECTORY/cert.pem") /run/coturn/turnserver.cfg
              ${getExe pkgs.replace-secret} @pkey@ <(echo -n "$CREDENTIALS_DIRECTORY/pkey.pem") /run/coturn/turnserver.cfg
            '');
        in
        (optionalAttrs (preStart' != "") { preStart = mkAfter preStart'; })
        // (optionalAttrs cfg.useAcmeCertificates {
          serviceConfig.LoadCredential = [
            "cert.pem:${dir}/fullchain.pem"
            "pkey.pem:${dir}/key.pem"
          ];
        });
    }
  ]);
}
