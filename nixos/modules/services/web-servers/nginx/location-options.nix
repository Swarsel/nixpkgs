# This file defines the options that can be used both for the Nginx
# main server configuration, and for the virtual hosts.  (The latter
# has additional options that affect the web server as a whole, like
# the user/group to run under.)

{ config, lib }:

with lib;

{
  options = {
    alias = mkOption {
      default = null;

      description = ''
        Alias directory for requests.
      '';

      example = "/your/alias/directory";
      type = types.nullOr types.path;
    };

    basicAuth = mkOption {
      default = { };

      description = ''
        Basic Auth protection for a vhost.

        WARNING: This is implemented to store the password in plain text in the
        Nix store.
      '';

      example = literalExpression ''
        {
          user = "password";
        };
      '';

      type = types.attrsOf types.str;
    };

    basicAuthFile = mkOption {
      default = null;

      description = ''
        Basic Auth password file for a vhost.
        Can be created by running {command}`nix-shell --packages apacheHttpd --run 'htpasswd -B -c FILENAME USERNAME'`.
      '';

      type = types.nullOr types.path;
    };

    extraConfig = mkOption {
      default = "";

      description = ''
        These lines go to the end of the location verbatim.
      '';

      type = types.lines;
    };

    fastcgiParams = mkOption {
      default = { };

      description = ''
        FastCGI parameters to override.  Unlike in the Nginx
        configuration file, overriding only some default parameters
        won't unset the default values for other parameters.
      '';

      type = types.attrsOf (types.either types.str types.path);
    };

    index = mkOption {
      default = null;

      description = ''
        Adds index directive.
      '';

      example = "index.php index.html";
      type = types.nullOr types.str;
    };

    priority = mkOption {
      default = 1000;

      description = ''
        Order of this location block in relation to the others in the vhost.
        The semantics are the same as with `lib.mkOrder`. Smaller values have
        a greater priority.
      '';

      type = types.int;
    };

    proxyPass = mkOption {
      default = null;

      description = ''
        Adds proxy_pass directive and sets recommended proxy headers if
        recommendedProxySettings is enabled.
      '';

      example = "http://www.example.org/";
      type = types.nullOr types.str;
    };

    proxyWebsockets = mkOption {
      default = false;

      description = ''
        Whether to support proxying websocket connections with HTTP/1.1.
      '';

      example = true;
      type = types.bool;
    };

    recommendedProxySettings = mkOption {
      default = config.services.nginx.recommendedProxySettings;
      defaultText = literalExpression "config.services.nginx.recommendedProxySettings";

      description = ''
        Enable recommended proxy settings.
      '';

      type = types.bool;
    };

    recommendedUwsgiSettings = mkOption {
      default = config.services.nginx.recommendedUwsgiSettings;
      defaultText = literalExpression "config.services.nginx.recommendedUwsgiSettings";

      description = ''
        Enable recommended uwsgi settings.
      '';

      type = types.bool;
    };

    return = mkOption {
      default = null;

      description = ''
        Adds a return directive, for e.g. redirections.
      '';

      example = "301 http://example.com$request_uri";

      type =
        with types;
        nullOr (oneOf [
          str
          int
        ]);
    };

    root = mkOption {
      default = null;

      description = ''
        Root directory for requests.
      '';

      example = "/your/root/directory";
      type = types.nullOr types.path;
    };

    tryFiles = mkOption {
      default = null;

      description = ''
        Adds try_files directive.
      '';

      example = "$uri =404";
      type = types.nullOr types.str;
    };

    uwsgiPass = mkOption {
      default = null;

      description = ''
        Adds uwsgi_pass directive and sets recommended proxy headers if
        recommendedUwsgiSettings is enabled.
      '';

      example = "unix:/run/example/example.sock";
      type = types.nullOr types.str;
    };
  };
}
