{
  config,
  lib,
  ...
}:

let
  inherit (lib)
    literalExpression
    mkOption
    types
    ;

  inherit (import ./common.nix { inherit lib; }) tlsRecommendationsOption;
in
{
  options = {
    acme = mkOption {
      default = null;
      description = "ACME options for virtual host.";

      type = types.nullOr (
        types.addCheck (types.submodule {
          options = {
            enable = mkOption {
              default = false;

              description = ''
                Whether to ask Let’s Encrypt to sign a certificate for this
                virtual host. Alternatively, an existing host can be used thru
                {option}`acme.useHost`.
              '';

              type = types.bool;
            };

            root = mkOption {
              default = "/var/lib/acme/acme-challenge";

              description = ''
                Directory for the ACME challenge, which is **public**. Don’t put
                certs or keys in here. Set to `null` to inherit from
                config.security.acme.
              '';

              type = types.nullOr types.path;
            };

            useHost = mkOption {
              default = null;

              description = ''
                An existing Let’s Encrypt certificate to use for this virtual
                host. This is useful if you have many subdomains and want to
                avoid hitting the [rate
                limit](https://letsencrypt.org/docs/rate-limits). Alternately,
                you can generate a certificate through {option}`acme.enable`.
                Note that this option neither creates any certificates nor does
                it add subdomains to existing ones — you will need to create
                them manually using [](#opt-security.acme.certs).
              '';

              type = types.nullOr types.nonEmptyStr;
            };
          };
        }) (a: (a.enable || a.useHost != null) && !(a.enable && a.useHost != null))
      );
    };

    host = mkOption {
      default = null;

      description = ''
        Set the host address for this virtual host. If unset, the default is to
        listen on all network interfaces.
      '';

      example = "127.0.0.1";
      type = types.nullOr types.nonEmptyStr;
    };

    http = mkOption {
      default = null;
      description = "HTTP options for virtual host";

      type = types.nullOr (
        types.submodule {
          options = {
            port = mkOption {
              default = config.services.h2o.defaultHTTPListenPort;

              defaultText = literalExpression ''
                config.services.h2o.defaultHTTPListenPort
              '';

              description = ''
                Override the default HTTP port for this virtual host.
              '';

              example = literalExpression "8080";
              type = types.port;
            };
          };
        }
      );
    };

    serverAliases = mkOption {
      default = [ ];

      description = ''
        Additional names of virtual hosts served by this virtual host
        configuration.
      '';

      example = [
        "www.example.org"
        "example.org"
      ];

      type = types.listOf types.nonEmptyStr;
    };

    serverName = mkOption {
      default = null;

      description = ''
        Server name to be used for this virtual host. Defaults to attribute
        name in hosts.
      '';

      example = "example.org";
      type = types.nullOr types.nonEmptyStr;
    };

    settings = mkOption {
      default = { };

      description = ''
        Attrset to be transformed into YAML for host config. Note that the HTTP
        / TLS configurations will override these config values. See
        <https://h2o.examp1e.net/configure/base_directives.html#hosts>.
      '';

      type = types.attrs;
    };

    tls = mkOption {
      default = null;
      description = "TLS options for virtual host";

      type = types.nullOr (
        types.submodule {
          options = {
            extraSettings = mkOption {
              default = { };

              description = ''
                Additional TLS/SSL-related configuration options. See
                <https://h2o.examp1e.net/configure/base_directives.html#listen-ssl>.
              '';

              example =
                literalExpression
                  # nix
                  ''
                    {
                      minimum-version = "TLSv1.3";
                    }
                  '';

              type = types.attrs;
            };

            identity = mkOption {
              default = [ ];

              description = ''
                Key / certificate pairs for the virtual host.
              '';

              example =
                literalExpression
                  # nix
                  ''
                    [
                      {
                        key-file = "/path/to/rsa.key";
                        certificate-file = "/path/to/rsa.crt";
                      }
                      {
                        key-file = "/path/to/ecdsa.key";
                        certificate-file = "/path/to/ecdsa.crt";
                      }
                    ]
                  '';

              type = types.listOf (
                types.submodule {
                  options = {
                    certificate-file = mkOption {
                      description = ''
                        Path to certificate file. See
                        <https://h2o.examp1e.net/configure/base_directives.html#certificate-file>.
                      '';

                      type = types.path;
                    };

                    key-file = mkOption {
                      description = ''
                        Path to key file. See
                        <https://h2o.examp1e.net/configure/base_directives.html#key-file>.
                      '';

                      type = types.path;
                    };
                  };
                }
              );
            };

            policy = mkOption {
              description = ''
                `add` will additionally listen for TLS connections. `only` will
                disable   TLS connections. `force` will redirect non-TLS traffic
                to the TLS connection.
              '';

              example = "force";

              type = types.enum [
                "add"
                "only"
                "force"
              ];
            };

            port = mkOption {
              default = config.services.h2o.defaultTLSListenPort;

              defaultText = literalExpression ''
                config.services.h2o.defaultTLSListenPort
              '';

              description = ''
                Override the default TLS port for this virtual host.
              '';

              example = 8443;
              type = types.port;
            };

            quic = mkOption {
              default = null;

              description = ''
                Enables HTTP/3 over QUIC on the UDP port for TLS. The attrset
                provides fine-turning for QUIC behavior, but can be empty. See
                <https://h2o.examp1e.net/configure/http3_directives.html#quic-attributes>.
              '';

              example =
                literalExpression
                  # nix
                  ''
                    {
                      amp-limit = 2;
                      handshake-timeout-rtt-multiplier = 300;
                      retry = "ON";
                    }
                  '';

              type = types.nullOr types.attrs;
            };

            recommendations = tlsRecommendationsOption;

            redirectCode = mkOption {
              default = 301;

              description = ''
                HTTP status used by `globalRedirect` & `forceSSL`. Possible
                usecases include temporary (302, 307) redirects, keeping the
                request method & body (307, 308), or explicitly resetting the
                method to GET (303). See
                <https://developer.mozilla.org/en-US/docs/Web/HTTP/Redirections>.
              '';

              example = 308;
              type = types.ints.between 300 399;
            };
          };
        }
      );
    };
  };
}
