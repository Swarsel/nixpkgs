{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cloudflared;

  certificateFile = lib.mkOption {
    default = null;

    description = ''
      Account certificate file, necessary to create, delete and manage tunnels. It can be obtained by running `cloudflared login`.

      Note that this is **necessary** for a fully declarative set up, as routes can not otherwise be created outside of the Cloudflare interface.

      See [Cert.pem](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-useful-terms/#certpem) for information about the file, and [Tunnel permissions](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/do-more-with-tunnels/local-management/tunnel-permissions/) for a comparison between the account certificate and the tunnel credentials file.
    '';

    type = with lib.types; nullOr path;
  };

  originRequest = {
    caPool = lib.mkOption {
      default = null;

      description = ''
        Path to the certificate authority (CA) for the certificate of your origin. This option should be used only if your certificate is not signed by Cloudflare.
      '';

      example = "";
      type = with lib.types; nullOr (either str path);
    };

    connectTimeout = lib.mkOption {
      default = null;

      description = ''
        Timeout for establishing a new TCP connection to your origin server. This excludes the time taken to establish TLS, which is controlled by [tlsTimeout](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/configuration/local-management/ingress/#tlstimeout).
      '';

      example = "30s";
      type = with lib.types; nullOr str;
    };

    disableChunkedEncoding = lib.mkOption {
      default = null;

      description = ''
        Disables chunked transfer encoding. Useful if you are running a WSGI server.
      '';

      example = false;
      type = with lib.types; nullOr bool;
    };

    httpHostHeader = lib.mkOption {
      default = null;

      description = ''
        Sets the HTTP `Host` header on requests sent to the local service.
      '';

      example = "";
      type = with lib.types; nullOr str;
    };

    keepAliveConnections = lib.mkOption {
      default = null;

      description = ''
        Maximum number of idle keepalive connections between Tunnel and your origin. This does not restrict the total number of concurrent connections.
      '';

      example = 100;
      type = with lib.types; nullOr int;
    };

    keepAliveTimeout = lib.mkOption {
      default = null;

      description = ''
        Timeout after which an idle keepalive connection can be discarded.
      '';

      example = "1m30s";
      type = with lib.types; nullOr str;
    };

    noHappyEyeballs = lib.mkOption {
      default = null;

      description = ''
        Disable the “happy eyeballs” algorithm for IPv4/IPv6 fallback if your local network has misconfigured one of the protocols.
      '';

      example = false;
      type = with lib.types; nullOr bool;
    };

    noTLSVerify = lib.mkOption {
      default = null;

      description = ''
        Disables TLS verification of the certificate presented by your origin. Will allow any certificate from the origin to be accepted.
      '';

      example = false;
      type = with lib.types; nullOr bool;
    };

    originServerName = lib.mkOption {
      default = null;

      description = ''
        Hostname that `cloudflared` should expect from your origin server certificate.
      '';

      example = "";
      type = with lib.types; nullOr str;
    };

    proxyAddress = lib.mkOption {
      default = null;

      description = ''
        `cloudflared` starts a proxy server to translate HTTP traffic into TCP when proxying, for example, SSH or RDP. This configures the listen address for that proxy.
      '';

      example = "127.0.0.1";
      type = with lib.types; nullOr str;
    };

    proxyPort = lib.mkOption {
      default = null;

      description = ''
        `cloudflared` starts a proxy server to translate HTTP traffic into TCP when proxying, for example, SSH or RDP. This configures the listen port for that proxy. If set to zero, an unused port will randomly be chosen.
      '';

      example = 0;
      type = with lib.types; nullOr int;
    };

    proxyType = lib.mkOption {
      default = null;

      description = ''
        `cloudflared` starts a proxy server to translate HTTP traffic into TCP when proxying, for example, SSH or RDP. This configures what type of proxy will be started. Valid options are:

        - `""` for the regular proxy
        - `"socks"` for a SOCKS5 proxy. Refer to the [tutorial on connecting through Cloudflare Access using kubectl](https://developers.cloudflare.com/cloudflare-one/tutorials/kubectl/) for more information.
      '';

      example = "";

      type =
        with lib.types;
        nullOr (enum [
          ""
          "socks"
        ]);
    };

    tcpKeepAlive = lib.mkOption {
      default = null;

      description = ''
        The timeout after which a TCP keepalive packet is sent on a connection between Tunnel and the origin server.
      '';

      example = "30s";
      type = with lib.types; nullOr str;
    };

    tlsTimeout = lib.mkOption {
      default = null;

      description = ''
        Timeout for completing a TLS handshake to your origin server, if you have chosen to connect Tunnel to an HTTPS server.
      '';

      example = "10s";
      type = with lib.types; nullOr str;
    };
  };
in
{
  imports = [
    (lib.mkRemovedOptionModule
      [
        "services"
        "cloudflared"
        "user"
      ]
      ''
        Cloudflared now uses a dynamic user, and this option no longer has any effect.

        If the user is still necessary, please define it manually using users.users.cloudflared.
      ''
    )

    (lib.mkRemovedOptionModule
      [
        "services"
        "cloudflared"
        "group"
      ]
      ''
        Cloudflared now uses a dynamic user, and this option no longer has any effect.

        If the group is still necessary, please define it manually using users.groups.cloudflared.
      ''
    )
  ];

  options.services.cloudflared = {
    inherit certificateFile;
    enable = lib.mkEnableOption "Cloudflare Tunnel client daemon (formerly Argo Tunnel)";
    package = lib.mkPackageOption pkgs "cloudflared" { };

    tunnels = lib.mkOption {
      default = { };

      description = ''
        Cloudflare tunnels.
      '';

      example = {
        "00000000-0000-0000-0000-000000000000" = {
          credentialsFile = "/tmp/test";
          default = "http_status:404";

          ingress = {
            "*.domain1.com" = {
              service = "http://localhost:80";
            };
          };
        };
      };

      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              inherit certificateFile originRequest;

              credentialsFile = lib.mkOption {
                description = ''
                  Credential file.

                  See [Credentials file](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-useful-terms/#credentials-file).
                '';

                type = lib.types.path;
              };

              default = lib.mkOption {
                description = ''
                  Catch-all service if no ingress matches.

                  See `service`.
                '';

                example = "http_status:404";
                type = lib.types.str;
              };

              edgeIPVersion = lib.mkOption {
                default = "4";

                description = ''
                  Specifies the IP address version (IPv4 or IPv6) used to establish a connection between `cloudflared` and the Cloudflare global network.

                  The value `auto` relies on the host operating system to determine which IP version to select. The first IP version returned from the DNS resolution of the region lookup will be used as the primary set. In dual IPv6 and IPv4 network setups, `cloudflared` will separate the IP versions into two address sets that will be used to fallback in connectivity failure scenarios.

                  See [Tunnel run parameters](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/configure-tunnels/cloudflared-parameters/run-parameters/#edge-ip-version).
                '';

                example = "auto";

                type = lib.types.enum [
                  "auto"
                  "4"
                  "6"
                ];
              };

              ingress = lib.mkOption {
                default = { };

                description = ''
                  Ingress rules.

                  See [Ingress rules](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/configuration/local-management/ingress/).
                '';

                example = {
                  "*.anotherone.com" = "http://localhost:80";
                  "*.domain.com" = "http://localhost:80";
                };

                type =
                  with lib.types;
                  attrsOf (
                    either str (
                      submodule (
                        { hostname, ... }:
                        {
                          options = {
                            inherit originRequest;

                            path = lib.mkOption {
                              default = null;

                              description = ''
                                Path filter.

                                If not specified, all paths will be matched.
                              '';

                              example = "/*.(jpg|png|css|js)";
                              type = with lib.types; nullOr str;
                            };

                            service = lib.mkOption {
                              default = null;

                              description = ''
                                Service to pass the traffic.

                                See [Supported protocols](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/configuration/local-management/ingress/#supported-protocols).
                              '';

                              example = "http://localhost:80, tcp://localhost:8000, unix:/home/production/echo.sock, hello_world or http_status:404";
                              type = with lib.types; nullOr str;
                            };

                          };
                        }
                      )
                    )
                  );
              };

              protocol = lib.mkOption {
                default = "auto";

                description = ''
                  Specifies the protocol used to establish a connection between `cloudflared` and the Cloudflare global network.

                  The value `auto` lets `cloudflared` choose the protocol (currently QUIC, falling back to HTTP/2).
                  Set to `http2` to work around QUIC/UDP connectivity issues, such as restrictive firewalls, broken UDP path MTU, or QUIC interop bugs.
                  Set to `quic` to force QUIC.

                  See [Tunnel run parameters](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/configure-tunnels/cloudflared-parameters/run-parameters/#protocol).
                '';

                example = "http2";

                type = lib.types.enum [
                  "auto"
                  "http2"
                  "quic"
                ];
              };

              warp-routing = {
                enabled = lib.mkOption {
                  default = null;

                  description = ''
                    Enable warp routing.

                    See [Connect from WARP to a private network on Cloudflare using Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/tutorials/warp-to-tunnel/).
                  '';

                  type = with lib.types; nullOr bool;
                };
              };
            };
          }
        )
      );
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = lib.mapAttrs' (
      name: tunnel:
      let
        filterConfig = lib.attrsets.filterAttrsRecursive (
          _: v:
          !builtins.elem v [
            null
            [ ]
            { }
          ]
        );

        filterIngressSet = lib.filterAttrs (_: v: builtins.typeOf v == "set");
        filterIngressStr = lib.filterAttrs (_: v: builtins.typeOf v == "string");

        ingressesSet = filterIngressSet tunnel.ingress;
        ingressesStr = filterIngressStr tunnel.ingress;

        fullConfig = filterConfig {
          credentials-file = "/run/credentials/cloudflared-tunnel-${name}.service/credentials.json";

          ingress =
            (map (
              key:
              {
                hostname = key;
              }
              // lib.getAttr key (filterConfig (filterConfig ingressesSet))
            ) (lib.attrNames ingressesSet))
            ++ (map (key: {
              hostname = key;
              service = lib.getAttr key ingressesStr;
            }) (lib.attrNames ingressesStr))
            ++ [ { service = tunnel.default; } ];

          originRequest = filterConfig tunnel.originRequest;
          tunnel = name;
          warp-routing = filterConfig tunnel.warp-routing;
        };

        mkConfigFile = pkgs.writeText "cloudflared.yml" (builtins.toJSON fullConfig);
        certFile = if (tunnel.certificateFile != null) then tunnel.certificateFile else cfg.certificateFile;
      in
      lib.nameValuePair "cloudflared-tunnel-${name}" {
        after = [
          "network.target"
          "network-online.target"
        ];

        environment = {
          TUNNEL_EDGE_IP_VERSION = tunnel.edgeIPVersion;
          TUNNEL_ORIGIN_CERT = lib.mkIf (certFile != null) "%d/cert.pem";
          TUNNEL_TRANSPORT_PROTOCOL = tunnel.protocol;
        };

        serviceConfig = {
          DynamicUser = true;
          ExecStart = "${cfg.package}/bin/cloudflared tunnel --config=${mkConfigFile} --no-autoupdate run";

          LoadCredential = [
            "credentials.json:${tunnel.credentialsFile}"
          ]
          ++ (lib.optional (certFile != null) "cert.pem:${certFile}");

          Restart = "on-failure";
          RuntimeDirectory = "cloudflared-tunnel-${name}";
          RuntimeDirectoryMode = "0400";
        };

        wantedBy = [ "multi-user.target" ];

        wants = [
          "network.target"
          "network-online.target"
        ];
      }
    ) config.services.cloudflared.tunnels;

    systemd.targets = lib.mapAttrs' (
      name: tunnel:
      lib.nameValuePair "cloudflared-tunnel-${name}" {
        after = [ "cloudflared-tunnel-${name}.service" ];
        description = "Cloudflare tunnel '${name}' target";
        requires = [ "cloudflared-tunnel-${name}.service" ];
        unitConfig.StopWhenUnneeded = true;
      }
    ) config.services.cloudflared.tunnels;
  };

  meta.maintainers = with lib.maintainers; [
    bbigras
    anpin
  ];
}
