{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.molly-brown;
  settingsFormat = pkgs.formats.toml { };
  configFile = settingsFormat.generate "molly-brown.toml" cfg.settings;
in
{

  options.services.molly-brown = {

    enable = mkEnableOption "Molly-Brown Gemini server";

    certPath = mkOption {
      description = ''
        Path to TLS certificate. An ACME certificate and key may be
        shared with an HTTP server, but only if molly-brown has
        permissions allowing it to read such keys.

        As an example:
        ```
        systemd.services.molly-brown.serviceConfig.SupplementaryGroups =
          [ config.security.acme.certs."example.com".group ];
        ```
      '';

      example = "/var/lib/acme/example.com/cert.pem";
      type = types.path;
    };

    docBase = mkOption {
      description = "Base directory for Gemini content.";
      example = "/var/lib/molly-brown";
      type = types.path;
    };

    hostName = mkOption {
      default = config.networking.hostName;
      defaultText = literalExpression "config.networking.hostName";

      description = ''
        The hostname to respond to requests for. Requests for URLs with
        other hosts will result in a status 53 (PROXY REQUEST REFUSED)
        response.
      '';

      type = types.str;
    };

    keyPath = mkOption {
      description = "Path to TLS key. See {option}`CertPath`.";
      example = "/var/lib/acme/example.com/key.pem";
      type = types.path;
    };

    port = mkOption {
      default = 1965;

      description = ''
        TCP port for molly-brown to bind to.
      '';

      type = types.port;
    };

    settings = mkOption {
      inherit (settingsFormat) type;
      default = { };

      description = ''
        molly-brown configuration. Refer to
        <https://tildegit.org/solderpunk/molly-brown/src/branch/master/example.conf>
        for details on supported values.
      '';
    };

  };

  config = mkIf cfg.enable {

    services.molly-brown.settings =
      let
        logDir = "/var/log/molly-brown";
      in
      {
        AccessLog = "${logDir}/access.log";
        CertPath = cfg.certPath;
        DocBase = cfg.docBase;
        ErrorLog = "${logDir}/error.log";
        Hostname = cfg.hostName;
        KeyPath = cfg.keyPath;
        Port = cfg.port;
      };

    systemd.services.molly-brown = {
      after = [ "network.target" ];
      description = "Molly Brown gemini server";

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkgs.molly-brown}/bin/molly-brown -c ${configFile}";
        LogsDirectory = "molly-brown";
        Restart = "always";
      };

      wantedBy = [ "multi-user.target" ];
    };

  };

}
