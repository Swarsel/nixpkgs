# This file defines the options that can be used both for the Nginx
# main server configuration, and for the virtual hosts.  (The latter
# has additional options that affect the web server as a whole, like
# the user/group to run under.)

{ config, lib, ... }:

with lib;
{
  options = {
    acmeFallbackHost = mkOption {
      default = null;

      description = ''
        Host which to proxy requests to if ACME challenge is not found. Useful
        if you want multiple hosts to be able to verify the same domain name.

        With this option, you could request certificates for the present domain
        with an ACME client that is running on another host, which you would
        specify here.
      '';

      type = types.nullOr types.str;
    };

    acmeRoot = mkOption {
      default = "/var/lib/acme/acme-challenge";

      description = ''
        Directory for the ACME challenge, which is **public**. Don't put certs or keys in here.
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

    default = mkOption {
      default = false;

      description = ''
        Makes this vhost the default.
      '';

      type = types.bool;
    };

    enableACME = mkOption {
      default = false;

      description = ''
        Whether to ask Let's Encrypt to sign a certificate for this vhost.
        Alternately, you can use an existing certificate through {option}`useACMEHost`.
      '';

      type = types.bool;
    };

    extraConfig = mkOption {
      default = "";

      description = ''
        These lines go to the end of the vhost verbatim.
      '';

      type = types.lines;
    };

    forceSSL = mkOption {
      default = false;

      description = ''
        Whether to add a separate nginx server block that redirects (defaults
        to 301, configurable with `redirectCode`) all plain HTTP traffic to
        HTTPS. This will set defaults for `listen` to listen on all interfaces
        on the respective default ports (80, 443), where the non-SSL listens
        are used for the redirect vhosts.
      '';

      type = types.bool;
    };

    globalRedirect = mkOption {
      default = null;

      description = ''
        If set, all requests for this host are redirected (defaults to 301,
        configurable with `redirectCode`) to the given hostname.
      '';

      example = "newserver.example.org";
      type = types.nullOr types.str;
    };

    http2 = mkOption {
      default = true;

      description = ''
        Whether to enable the HTTP/2 protocol.
        Note that (as of writing) due to nginx's implementation, to disable
        HTTP/2 you have to disable it on all vhosts that use a given
        IP address / port.
        If there is one server block configured to enable http2, then it is
        enabled for all server blocks on this IP.
        See <https://stackoverflow.com/a/39466948/263061>.
      '';

      type = types.bool;
    };

    http3 = mkOption {
      default = true;

      description = ''
        Whether to enable the HTTP/3 protocol.
        This requires activating the QUIC transport protocol
        `services.nginx.virtualHosts.<name>.quic = true;`.
        Note that HTTP/3 support is experimental and *not* yet recommended for production.
        Read more at <https://quic.nginx.org/>
        HTTP/3 availability must be manually advertised, preferably in each location block.
      '';

      type = types.bool;
    };

    http3_hq = mkOption {
      default = false;

      description = ''
        Whether to enable the HTTP/0.9 protocol negotiation used in QUIC interoperability tests.
        This requires activating the QUIC transport protocol
        `services.nginx.virtualHosts.<name>.quic = true;`.
        Note that special application protocol support is experimental and *not* yet recommended for production.
        Read more at <https://quic.nginx.org/>
      '';

      type = types.bool;
    };

    kTLS = mkOption {
      default = false;

      description = ''
        Whether to enable kTLS support.
        Implementing TLS in the kernel (kTLS) improves performance by significantly
        reducing the need for copying operations between user space and the kernel.
        Required Nginx version 1.21.4 or later.
      '';

      type = types.bool;
    };

    listen = mkOption {
      default = [ ];

      description = ''
        Listen addresses and ports for this virtual host.
        IPv6 addresses must be enclosed in square brackets.
        Note: this option overrides `addSSL`
        and `onlySSL`.

        If you only want to set the addresses manually and not
        the ports, take a look at `listenAddresses`.
      '';

      example = [
        {
          addr = "195.154.1.1";
          port = 443;
          ssl = true;
        }
        {
          addr = "192.154.1.1";
          port = 80;
        }
        { addr = "unix:/var/run/nginx.sock"; }
      ];

      type =
        with types;
        listOf (submodule {
          options = {
            addr = mkOption {
              description = "Listen address.";
              type = str;
            };

            extraParameters = mkOption {
              default = [ ];
              description = "Extra parameters of this listen directive.";

              example = [
                "backlog=1024"
                "deferred"
              ];

              type = listOf str;
            };

            port = mkOption {
              default = null;

              description = ''
                Port number to listen on.
                If unset and the listen address is not a socket then nginx defaults to 80.
              '';

              type = types.nullOr port;
            };

            proxyProtocol = mkOption {
              default = false;
              description = "Enable PROXY protocol.";
              type = bool;
            };

            ssl = mkOption {
              default = false;
              description = "Enable SSL.";
              type = bool;
            };
          };
        });
    };

    listenAddresses = mkOption {
      default = [ ];

      description = ''
        Listen addresses for this virtual host.
        Compared to `listen` this only sets the addresses
        and the ports are chosen automatically.

        Note: This option overrides `networking.enableIPv6`
      '';

      example = [
        "127.0.0.1"
        "[::1]"
      ];

      type = with types; listOf str;
    };

    locations = mkOption {
      default = { };
      description = "Declarative location config";

      example = literalExpression ''
        {
          "/" = {
            proxyPass = "http://localhost:3000";
          };
        };
      '';

      type = types.attrsOf (
        types.submodule (
          import ./location-options.nix {
            inherit lib config;
          }
        )
      );
    };

    onlySSL = mkOption {
      default = false;

      description = ''
        Whether to enable HTTPS and reject plain HTTP connections. This will set
        defaults for `listen` to listen on all interfaces on port 443.
      '';

      type = types.bool;
    };

    quic = mkOption {
      default = false;

      description = ''
        Whether to enable the QUIC transport protocol.
        Note that QUIC support is experimental and
        *not* yet recommended for production.
        Read more at <https://quic.nginx.org/>
      '';

      type = types.bool;
    };

    redirectCode = mkOption {
      default = 301;

      description = ''
        HTTP status used by `globalRedirect` and `forceSSL`. Possible usecases
        include temporary (302, 307) redirects, keeping the request method and
        body (307, 308), or explicitly resetting the method to GET (303).
        See <https://developer.mozilla.org/en-US/docs/Web/HTTP/Redirections>.
      '';

      example = 308;
      type = types.ints.between 300 399;
    };

    rejectSSL = mkOption {
      default = false;

      description = ''
        Whether to listen for and reject all HTTPS connections to this vhost. Useful in
        [default](#opt-services.nginx.virtualHosts._name_.default)
        server blocks to avoid serving the certificate for another vhost. Uses the
        `ssl_reject_handshake` directive available in nginx versions
        1.19.4 and above.
      '';

      type = types.bool;
    };

    reuseport = mkOption {
      default = false;

      description = ''
        Create an individual listening socket .
        It is required to specify only once on one of the hosts.
      '';

      type = types.bool;
    };

    root = mkOption {
      default = null;

      description = ''
        The path of the web root directory.
      '';

      example = "/data/webserver/docs";
      type = types.nullOr types.path;
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

      type = types.listOf types.str;
    };

    serverName = mkOption {
      default = null;

      description = ''
        Name of this virtual host. Defaults to attribute name in virtualHosts.
      '';

      example = "example.org";
      type = types.nullOr types.str;
    };

    sslCertificate = mkOption {
      description = "Path to server SSL certificate.";
      example = "/var/host.cert";
      type = types.path;
    };

    sslCertificateKey = mkOption {
      description = "Path to server SSL certificate key.";
      example = "/var/host.key";
      type = types.path;
    };

    sslTrustedCertificate = mkOption {
      default = null;
      description = "Path to root SSL certificate for stapling and client certificates.";
      example = literalExpression ''"''${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"'';
      type = types.nullOr types.path;
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
}
