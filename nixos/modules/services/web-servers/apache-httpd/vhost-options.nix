{
  config,
  lib,
  name,
  ...
}:
let
  inherit (lib)
    literalExpression
    mkOption
    nameValuePair
    types
    ;
in
{
  options = {

    acmeRoot = mkOption {
      default = "/var/lib/acme/acme-challenge";

      description = ''
        Directory for the acme challenge which is PUBLIC, don't put certs or keys in here.
        Set to null to inherit from config.security.acme.
      '';

      type = types.nullOr types.str;
    };

    addSSL = mkOption {
      default = false;

      description = ''
        Whether to enable HTTPS in addition to plain HTTP. This will set defaults for
        `listen` to listen on all interfaces on the respective default
        ports (80, 443).
      '';

      type = types.bool;
    };

    adminAddr = mkOption {
      default = null;
      description = "E-mail address of the server administrator.";
      example = "admin@example.org";
      type = types.nullOr types.str;
    };

    documentRoot = mkOption {
      default = null;

      description = ''
        The path of Apache's document root directory.  If left undefined,
        an empty directory in the Nix store will be used as root.
      '';

      example = "/data/webserver/docs";
      type = types.nullOr types.path;
    };

    enableACME = mkOption {
      default = false;

      description = ''
        Whether to ask Let's Encrypt to sign a certificate for this vhost.
        Alternately, you can use an existing certificate through {option}`useACMEHost`.
      '';

      type = types.bool;
    };

    enableSSL = mkOption {
      default = false;
      type = types.bool;
      visible = false;
    };

    enableUserDir = mkOption {
      default = false;

      description = ''
        Whether to enable serving {file}`~/public_html` as
        `/~«username»`.
      '';

      type = types.bool;
    };

    extraConfig = mkOption {
      default = "";

      description = ''
        These lines go to httpd.conf verbatim. They will go after
        directories and directory aliases defined by default.
      '';

      example = ''
        <Directory /home>
          Options FollowSymlinks
          AllowOverride All
        </Directory>
      '';

      type = types.lines;
    };

    forceSSL = mkOption {
      default = false;

      description = ''
        Whether to add a separate nginx server block that permanently redirects (301)
        all plain HTTP traffic to HTTPS. This will set defaults for
        `listen` to listen on all interfaces on the respective default
        ports (80, 443), where the non-SSL listens are used for the redirect vhosts.
      '';

      type = types.bool;
    };

    globalRedirect = mkOption {
      default = null;

      description = ''
        If set, all requests for this host are redirected permanently to
        the given URL.
      '';

      example = "http://newserver.example.org/";
      type = types.nullOr types.str;
    };

    hostName = mkOption {
      default = name;
      description = "Canonical hostname for the server.";
      type = types.str;
    };

    http2 = mkOption {
      default = true;

      description = ''
        Whether to enable HTTP 2. HTTP/2 is supported in all multi-processing modules that come with httpd. *However, if you use the prefork mpm, there will
        be severe restrictions.* Refer to <https://httpd.apache.org/docs/2.4/howto/http2.html#mpm-config> for details.
      '';

      type = types.bool;
    };

    listen = mkOption {
      default = [ ];

      description = ''
        Listen addresses and ports for this virtual host.

        ::: {.note}
        This option overrides `addSSL`, `forceSSL` and `onlySSL`.

        If you only want to set the addresses manually and not the ports, take a look at `listenAddresses`.
        :::
      '';

      example = [
        {
          ip = "195.154.1.1";
          port = 443;
          ssl = true;
        }
        {
          ip = "192.154.1.1";
          port = 80;
        }
        {
          ip = "*";
          port = 8080;
        }
      ];

      type =
        with types;
        listOf (submodule {
          options = {
            ip = mkOption {
              default = "*";
              description = "IP to listen on. 0.0.0.0 for IPv4 only, * for all.";
              type = types.str;
            };

            port = mkOption {
              description = "Port to listen on";
              type = types.port;
            };

            ssl = mkOption {
              default = false;
              description = "Whether to enable SSL (https) support.";
              type = types.bool;
            };
          };
        });
    };

    listenAddresses = mkOption {
      default = [ "*" ];

      description = ''
        Listen addresses for this virtual host.
        Compared to `listen` this only sets the addresses
        and the ports are chosen automatically.
      '';

      example = [ "127.0.0.1" ];
      type = with types; nonEmptyListOf str;
    };

    locations = mkOption {
      default = { };

      description = ''
        Declarative location config. See <https://httpd.apache.org/docs/2.4/mod/core.html#location> for details.
      '';

      example = literalExpression ''
        {
          "/" = {
            proxyPass = "http://localhost:3000";
          };
          "/foo/bar.png" = {
            alias = "/home/eelco/some-file.png";
          };
        };
      '';

      type = with types; attrsOf (submodule (import ./location-options.nix));
    };

    logFormat = mkOption {
      default = "common";

      description = ''
        Log format for Apache's log files. Possible values are: combined, common, referer, agent.
      '';

      example = "combined";
      type = types.str;
    };

    onlySSL = mkOption {
      default = false;

      description = ''
        Whether to enable HTTPS and reject plain HTTP connections. This will set
        defaults for `listen` to listen on all interfaces on port 443.
      '';

      type = types.bool;
    };

    robotsEntries = mkOption {
      default = "";

      description = ''
        Specification of pages to be ignored by web crawlers. See <http://www.robotstxt.org/> for details.
      '';

      example = "Disallow: /foo/";
      type = types.lines;
    };

    servedDirs = mkOption {
      default = [ ];

      description = ''
        This option provides a simple way to serve static directories.
      '';

      example = [
        {
          dir = "/home/eelco/Dev/nix-homepage";
          urlPath = "/nix";
        }
      ];

      type = types.listOf types.attrs;
    };

    servedFiles = mkOption {
      default = [ ];

      description = ''
        This option provides a simple way to serve individual, static files.

        ::: {.note}
        This option has been deprecated and will be removed in a future
        version of NixOS. You can achieve the same result by making use of
        the `locations.<name>.alias` option.
        :::
      '';

      example = [
        {
          file = "/home/eelco/some-file.png";
          urlPath = "/foo/bar.png";
        }
      ];

      type = types.listOf types.attrs;
    };

    serverAliases = mkOption {
      default = [ ];

      description = ''
        Additional names of virtual hosts served by this virtual host configuration.
      '';

      example = [
        "www.example.org"
        "www.example.org:8080"
        "example.org"
      ];

      type = types.listOf types.str;
    };

    sslServerCert = mkOption {
      description = "Path to server SSL certificate.";
      example = "/var/host.cert";
      type = types.path;
    };

    sslServerChain = mkOption {
      default = null;
      description = "Path to server SSL chain file.";
      example = "/var/ca.pem";
      type = types.nullOr types.path;
    };

    sslServerKey = mkOption {
      description = "Path to server SSL certificate key.";
      example = "/var/host.key";
      type = types.path;
    };

    useACMEHost = mkOption {
      default = null;

      description = ''
        A host of an existing Let's Encrypt certificate to use.
        This is useful if you have many subdomains and want to avoid hitting the
        [rate limit](https://letsencrypt.org/docs/rate-limits).
        Alternately, you can generate a certificate through {option}`enableACME`.
        *Note that this option does not create any certificates, nor it does add subdomains to existing ones – you will need to create them manually using [](#opt-security.acme.certs).*
      '';

      type = types.nullOr types.str;
    };

  };

  config = {

    locations = builtins.listToAttrs (
      map (elem: nameValuePair elem.urlPath { alias = elem.file; }) config.servedFiles
    );

  };
}
