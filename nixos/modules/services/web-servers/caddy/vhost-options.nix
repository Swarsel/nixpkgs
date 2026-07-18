{ cfg }:
{
  config,
  lib,
  name,
  ...
}:
let
  inherit (lib) literalExpression mkOption types;
in
{
  options = {

    extraConfig = mkOption {
      default = "";

      description = ''
        Additional lines of configuration appended to this virtual host in the
        automatically generated `Caddyfile`.
      '';

      type = types.lines;
    };

    hostName = mkOption {
      default = name;
      description = "Canonical hostname for the server.";
      type = types.str;
    };

    listenAddresses = mkOption {
      default = [ ];

      description = ''
        A list of host interfaces to bind to for this virtual host.
      '';

      example = [
        "127.0.0.1"
        "::1"
      ];

      type = with types; listOf str;
    };

    logFormat = mkOption {
      default = ''
        output file ${cfg.logDir}/access-${lib.replaceStrings [ "/" " " ] [ "_" "_" ] config.hostName}.log
      '';

      defaultText = ''
        output file ''${config.services.caddy.logDir}/access-''${hostName}.log
      '';

      description = ''
        Configuration for HTTP request logging (also known as access logs). See
        <https://caddyserver.com/docs/caddyfile/directives/log#log>
        for details.
      '';

      example = literalExpression ''
        mkForce '''
          output discard
        ''';
      '';

      type = types.nullOr types.lines;
    };

    serverAliases = mkOption {
      default = [ ];

      description = ''
        Additional names of virtual hosts served by this virtual host configuration.
      '';

      example = [
        "www.example.org"
        "example.org"
      ];

      type = with types; listOf str;
    };

    useACMEHost = mkOption {
      default = null;

      description = ''
        A host of an existing Let's Encrypt certificate to use.
        This is mostly useful if you use DNS challenges but Caddy does not
        currently support your provider.

        *Note that this option does not create any certificates, nor
        does it add subdomains to existing ones – you will need to create them
        manually using [](#opt-security.acme.certs).*
      '';

      type = types.nullOr types.str;
    };

  };
}
