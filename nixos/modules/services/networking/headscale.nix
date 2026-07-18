{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.headscale;

  dataDir = "/var/lib/headscale";
  runDir = "/run/headscale";

  cliConfig = {
    # Turn off update checks since the origin of our package
    # is nixpkgs and not Github.
    disable_check_updates = true;
    unix_socket = "${runDir}/headscale.sock";
  };

  settingsFormat = pkgs.formats.yaml { };

  assertRemovedOption = option: message: {
    assertion = !lib.hasAttrByPath option cfg;

    message =
      "The option `services.headscale.${lib.options.showOption option}` was removed. " + message;
  };
in
{
  imports = with lib; [
    (mkRenamedOptionModule
      [ "services" "headscale" "derp" "autoUpdate" ]
      [ "services" "headscale" "settings" "derp" "auto_update_enabled" ]
    )
    (mkRenamedOptionModule
      [ "services" "headscale" "derp" "auto_update_enable" ]
      [ "services" "headscale" "settings" "derp" "auto_update_enabled" ]
    )
    (mkRenamedOptionModule
      [ "services" "headscale" "derp" "paths" ]
      [ "services" "headscale" "settings" "derp" "paths" ]
    )
    (mkRenamedOptionModule
      [ "services" "headscale" "derp" "updateFrequency" ]
      [ "services" "headscale" "settings" "derp" "update_frequency" ]
    )
    (mkRenamedOptionModule
      [ "services" "headscale" "derp" "urls" ]
      [ "services" "headscale" "settings" "derp" "urls" ]
    )
    (mkRenamedOptionModule
      [ "services" "headscale" "ephemeralNodeInactivityTimeout" ]
      [ "services" "headscale" "settings" "ephemeral_node_inactivity_timeout" ]
    )
    (mkRenamedOptionModule
      [ "services" "headscale" "logLevel" ]
      [ "services" "headscale" "settings" "log" "level" ]
    )
    (mkRenamedOptionModule
      [ "services" "headscale" "openIdConnect" "clientId" ]
      [ "services" "headscale" "settings" "oidc" "client_id" ]
    )
    (mkRenamedOptionModule
      [ "services" "headscale" "openIdConnect" "clientSecretFile" ]
      [ "services" "headscale" "settings" "oidc" "client_secret_path" ]
    )
    (mkRenamedOptionModule
      [ "services" "headscale" "openIdConnect" "issuer" ]
      [ "services" "headscale" "settings" "oidc" "issuer" ]
    )
    (mkRenamedOptionModule
      [ "services" "headscale" "serverUrl" ]
      [ "services" "headscale" "settings" "server_url" ]
    )
    (mkRenamedOptionModule
      [ "services" "headscale" "tls" "certFile" ]
      [ "services" "headscale" "settings" "tls_cert_path" ]
    )
    (mkRenamedOptionModule
      [ "services" "headscale" "tls" "keyFile" ]
      [ "services" "headscale" "settings" "tls_key_path" ]
    )
    (mkRenamedOptionModule
      [ "services" "headscale" "tls" "letsencrypt" "challengeType" ]
      [ "services" "headscale" "settings" "tls_letsencrypt_challenge_type" ]
    )
    (mkRenamedOptionModule
      [ "services" "headscale" "tls" "letsencrypt" "hostname" ]
      [ "services" "headscale" "settings" "tls_letsencrypt_hostname" ]
    )
    (mkRenamedOptionModule
      [ "services" "headscale" "tls" "letsencrypt" "httpListen" ]
      [ "services" "headscale" "settings" "tls_letsencrypt_listen" ]
    )

    (mkRemovedOptionModule [ "services" "headscale" "openIdConnect" "domainMap" ] ''
      Headscale no longer uses domain_map. If you're using an old version of headscale you can still set this option via services.headscale.settings.oidc.domain_map.
    '')
  ];

  options = {
    services.headscale = {
      enable = lib.mkEnableOption "headscale, Open Source coordination server for Tailscale";
      package = lib.mkPackageOption pkgs "headscale" { };

      address = lib.mkOption {
        default = "127.0.0.1";

        description = ''
          Listening address of headscale.
        '';

        example = "0.0.0.0";
        type = lib.types.str;
      };

      configFile = lib.mkOption {
        default = settingsFormat.generate "headscale.yaml" (
          lib.filterAttrsRecursive (n: v: v != null) cfg.settings
        );

        defaultText = lib.literalExpression ''(pkgs.formats.yaml { }).generate "headscale.yaml" (lib.filterAttrsRecursive (n: v: v != null) config.services.headscale.settings)'';

        description = ''
          Path to the configuration file of headscale.
        '';

        readOnly = true;
        type = lib.types.path;
      };

      group = lib.mkOption {
        default = "headscale";

        description = ''
          Group under which headscale runs.

          ::: {.note}
          If left as the default value this group will automatically be created
          on system activation, otherwise you are responsible for
          ensuring the user exists before the headscale service starts.
          :::
        '';

        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 8080;

        description = ''
          Listening port of headscale.
        '';

        example = 443;
        type = lib.types.port;
      };

      settings = lib.mkOption {
        description = ''
          Overrides to {file}`config.yaml` as a Nix attribute set.
          Check the [example config](https://github.com/juanfont/headscale/blob/main/config-example.yaml)
          for possible options.
        '';

        type = lib.types.submodule {
          options = {
            database = {
              postgres = {
                host = lib.mkOption {
                  default = null;
                  description = "Database host address.";
                  example = "127.0.0.1";
                  type = lib.types.nullOr lib.types.str;
                };

                name = lib.mkOption {
                  default = null;
                  description = "Database name.";
                  example = "headscale";
                  type = lib.types.nullOr lib.types.str;
                };

                password_file = lib.mkOption {
                  default = null;

                  description = ''
                    A file containing the password corresponding to
                    {option}`database.user`.
                  '';

                  example = "/run/keys/headscale-dbpassword";
                  type = lib.types.nullOr lib.types.path;
                };

                port = lib.mkOption {
                  default = null;
                  description = "Database host port.";
                  example = 3306;
                  type = lib.types.nullOr lib.types.port;
                };

                user = lib.mkOption {
                  default = null;
                  description = "Database user.";
                  example = "headscale";
                  type = lib.types.nullOr lib.types.str;
                };
              };

              sqlite = {
                path = lib.mkOption {
                  default = "${dataDir}/db.sqlite";
                  description = "Path to the sqlite3 database file.";
                  type = lib.types.nullOr lib.types.str;
                };

                write_ahead_log = lib.mkOption {
                  default = true;

                  description = ''
                    Enable WAL mode for SQLite. This is recommended for production environments.
                    <https://www.sqlite.org/wal.html>
                  '';

                  example = true;
                  type = lib.types.bool;
                };
              };

              type = lib.mkOption {
                default = "sqlite";

                description = ''
                  Database engine to use.
                  Please note that using Postgres is highly discouraged as it is only supported for legacy reasons.
                  All new development, testing and optimisations are done with SQLite in mind.
                '';

                example = "postgres";

                type = lib.types.enum [
                  "sqlite"
                  "sqlite3"
                  "postgres"
                ];
              };
            };

            derp = {
              auto_update_enabled = lib.mkOption {
                default = true;

                description = ''
                  Whether to automatically update DERP maps on a set frequency.
                '';

                example = false;
                type = lib.types.bool;
              };

              paths = lib.mkOption {
                default = [ ];

                description = ''
                  List of file paths containing DERP maps.
                  See [How Tailscale works](https://tailscale.com/blog/how-tailscale-works/) for more information on DERP maps.
                '';

                type = lib.types.listOf lib.types.path;
              };

              server.private_key_path = lib.mkOption {
                default = "${dataDir}/derp_server_private.key";

                description = ''
                  Path to derp private key file, generated automatically if it does not exist.
                '';

                type = lib.types.path;
              };

              update_frequency = lib.mkOption {
                default = "24h";

                description = ''
                  Frequency to update DERP maps.
                '';

                example = "5m";
                type = lib.types.str;
              };

              urls = lib.mkOption {
                default = [ "https://controlplane.tailscale.com/derpmap/default" ];

                description = ''
                  List of urls containing DERP maps.
                  See [How Tailscale works](https://tailscale.com/blog/how-tailscale-works/) for more information on DERP maps.
                '';

                type = lib.types.listOf lib.types.str;
              };
            };

            dns = {
              base_domain = lib.mkOption {
                default = "";

                description = ''
                  Defines the base domain to create the hostnames for MagicDNS.
                  This domain must be different from the {option}`server_url`
                  domain.
                  {option}`base_domain` must be a FQDN, without the trailing dot.
                  The FQDN of the hosts will be `hostname.base_domain` (e.g.
                  `myhost.tailnet.example.com`).
                '';

                example = "tailnet.example.com";
                type = lib.types.str;
              };

              extra_records = lib.mkOption {
                default = null;

                description = ''
                  Extra DNS records to expose to clients.
                '';

                example = ''
                  [ {
                    name = "grafana.tailnet.example.com";
                    type = "A";
                    example = "100.64.0.3";
                  } ]
                '';

                type = lib.types.nullOr (
                  lib.types.listOf (
                    lib.types.submodule {
                      options = {
                        name = lib.mkOption {
                          description = "DNS record name.";
                          example = "grafana.tailnet.example.com";
                          type = lib.types.str;
                        };

                        type = lib.mkOption {
                          description = "DNS record type.";
                          example = "A";

                          type = lib.types.enum [
                            "A"
                            "AAAA"
                          ];
                        };

                        value = lib.mkOption {
                          description = "DNS record value (IP address).";
                          example = "100.64.0.3";
                          type = lib.types.str;
                        };
                      };
                    }
                  )
                );
              };

              extra_records_path = lib.mkOption {
                default = null;

                description = ''
                  Path to a JSON file containing extra DNS records.
                  This is mutually exclusive with {option}`extra_records`.
                '';

                example = "/run/headscale/records.json";
                type = lib.types.nullOr lib.types.str;
              };

              magic_dns = lib.mkOption {
                default = true;

                description = ''
                  Whether to use [MagicDNS](https://tailscale.com/kb/1081/magicdns/).
                '';

                example = false;
                type = lib.types.bool;
              };

              nameservers = {
                global = lib.mkOption {
                  default = [ ];

                  description = ''
                    List of nameservers to pass to Tailscale clients.
                  '';

                  type = lib.types.listOf lib.types.str;
                };
              };

              override_local_dns = lib.mkOption {
                default = true;

                description = ''
                  Whether to [override clients' DNS servers](https://tailscale.com/kb/1054/dns#override-dns-servers).
                '';

                example = false;
                type = lib.types.bool;
              };

              search_domains = lib.mkOption {
                default = [ ];

                description = ''
                  Search domains to inject to Tailscale clients.
                '';

                example = [ "mydomain.internal" ];
                type = lib.types.listOf lib.types.str;
              };

              split = lib.mkOption {
                default = { };

                description = ''
                  Split DNS configuration (map of domains and which DNS server to use for each).
                  See <https://tailscale.com/kb/1054/dns/>.
                '';

                example = {
                  "foo.bar.com" = [ "1.1.1.1" ];
                };

                type = lib.types.attrsOf (lib.types.listOf lib.types.str);
              };
            };

            ephemeral_node_inactivity_timeout = lib.mkOption {
              default = "30m";

              description = ''
                Time before an inactive ephemeral node is deleted.
              '';

              example = "5m";
              type = lib.types.str;
            };

            log = {
              format = lib.mkOption {
                default = "text";

                description = ''
                  headscale log format.
                '';

                example = "json";
                type = lib.types.str;
              };

              level = lib.mkOption {
                default = "info";

                description = ''
                  headscale log level.
                '';

                example = "debug";
                type = lib.types.str;
              };
            };

            noise.private_key_path = lib.mkOption {
              default = "${dataDir}/noise_private.key";

              description = ''
                Path to noise private key file, generated automatically if it does not exist.
              '';

              type = lib.types.path;
            };

            oidc = {
              allowed_domains = lib.mkOption {
                default = [ ];

                description = ''
                  Allowed principal domains. if an authenticated user's domain
                  is not in this list authentication request will be rejected.
                '';

                example = [ "example.com" ];
                type = lib.types.listOf lib.types.str;
              };

              allowed_users = lib.mkOption {
                default = [ ];

                description = ''
                  Users allowed to authenticate even if not in allowedDomains.
                '';

                example = [ "alice@example.com" ];
                type = lib.types.listOf lib.types.str;
              };

              client_id = lib.mkOption {
                default = "";

                description = ''
                  OpenID Connect client ID.
                '';

                type = lib.types.str;
              };

              client_secret_path = lib.mkOption {
                default = null;

                description = ''
                  Path to OpenID Connect client secret file. Expands environment variables in format ''${VAR}.
                '';

                type = lib.types.nullOr lib.types.str;
              };

              extra_params = lib.mkOption {
                default = { };

                description = ''
                  Custom query parameters to send with the Authorize Endpoint request.
                '';

                example = {
                  domain_hint = "example.com";
                };

                type = lib.types.attrsOf lib.types.str;
              };

              issuer = lib.mkOption {
                default = "";

                description = ''
                  URL to OpenID issuer.
                '';

                example = "https://openid.example.com";
                type = lib.types.str;
              };

              pkce = {
                enabled = lib.mkOption {
                  default = false;

                  description = ''
                    Enable or disable PKCE (Proof Key for Code Exchange) support.
                    PKCE adds an additional layer of security to the OAuth 2.0
                    authorization code flow by preventing authorization code
                    interception attacks
                    See https://datatracker.ietf.org/doc/html/rfc7636
                  '';

                  example = true;
                  type = lib.types.bool;
                };

                method = lib.mkOption {
                  default = "S256";

                  description = ''
                    PKCE method to use:
                      - plain: Use plain code verifier
                      - S256: Use SHA256 hashed code verifier (default, recommended)
                  '';

                  type = lib.types.str;
                };
              };

              scope = lib.mkOption {
                default = [
                  "openid"
                  "profile"
                  "email"
                ];

                description = ''
                  Scopes used in the OIDC flow.
                '';

                type = lib.types.listOf lib.types.str;
              };
            };

            policy = {
              mode = lib.mkOption {
                default = "file";

                description = ''
                  The mode can be "file" or "database" that defines
                  where the ACL policies are stored and read from.
                '';

                type = lib.types.enum [
                  "file"
                  "database"
                ];
              };

              path = lib.mkOption {
                default = null;

                description = ''
                  If the mode is set to "file", the path to a
                  HuJSON file containing ACL policies.
                '';

                type = lib.types.nullOr lib.types.path;
              };
            };

            prefixes =
              let
                prefDesc = ''
                  Each prefix consists of either an IPv4 or IPv6 address,
                  and the associated prefix length, delimited by a slash.
                  It must be within IP ranges supported by the Tailscale
                  client - i.e., subnets of 100.64.0.0/10 and fd7a:115c:a1e0::/48.
                '';
              in
              {
                allocation = lib.mkOption {
                  default = "sequential";

                  description = ''
                    Strategy used for allocation of IPs to nodes, available options:
                    - sequential (default): assigns the next free IP from the previous given IP.
                    - random: assigns the next free IP from a pseudo-random IP generator (crypto/rand).
                  '';

                  example = "random";

                  type = lib.types.enum [
                    "sequential"
                    "random"
                  ];
                };

                v4 = lib.mkOption {
                  default = "100.64.0.0/10";
                  description = prefDesc;
                  type = lib.types.str;
                };

                v6 = lib.mkOption {
                  default = "fd7a:115c:a1e0::/48";
                  description = prefDesc;
                  type = lib.types.str;
                };
              };

            server_url = lib.mkOption {
              default = "http://127.0.0.1:8080";

              description = ''
                The url clients will connect to.
              '';

              example = "https://myheadscale.example.com:443";
              type = lib.types.str;
            };

            tls_cert_path = lib.mkOption {
              default = null;

              description = ''
                Path to already created certificate.
              '';

              type = lib.types.nullOr lib.types.path;
            };

            tls_key_path = lib.mkOption {
              default = null;

              description = ''
                Path to key for already created certificate.
              '';

              type = lib.types.nullOr lib.types.path;
            };

            tls_letsencrypt_challenge_type = lib.mkOption {
              default = "HTTP-01";

              description = ''
                Type of ACME challenge to use, currently supported types:
                `HTTP-01` or `TLS-ALPN-01`.
              '';

              type = lib.types.enum [
                "TLS-ALPN-01"
                "HTTP-01"
              ];
            };

            tls_letsencrypt_hostname = lib.mkOption {
              default = "";

              description = ''
                Domain name to request a TLS certificate for.
              '';

              type = lib.types.nullOr lib.types.str;
            };

            tls_letsencrypt_listen = lib.mkOption {
              default = ":http";

              description = ''
                When HTTP-01 challenge is chosen, letsencrypt must set up a
                verification endpoint, and it will be listening on:
                `:http = port 80`.
              '';

              type = lib.types.nullOr lib.types.str;
            };
          };

          freeformType = settingsFormat.type;
        };
      };

      user = lib.mkOption {
        default = "headscale";

        description = ''
          User account under which headscale runs.

          ::: {.note}
          If left as the default value this user will automatically be created
          on system activation, otherwise you are responsible for
          ensuring the user exists before the headscale service starts.
          :::
        '';

        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = with cfg.settings; dns.magic_dns -> dns.base_domain != "";
        message = "dns.base_domain must be set when using MagicDNS";
      }
      {
        assertion = with cfg.settings; dns.override_local_dns -> dns.nameservers.global != [ ];
        message = "dns.nameservers.global must be set when overriding local DNS";
      }
      {
        assertion = with cfg.settings; dns.extra_records_path == null || dns.extra_records == null;
        message = "dns.extra_records and dns.extra_records_path are mutually exclusive";
      }
      (assertRemovedOption [ "settings" "acl_policy_path" ] "Use `policy.path` instead.")
      (assertRemovedOption [ "settings" "db_host" ] "Use `database.postgres.host` instead.")
      (assertRemovedOption [ "settings" "db_name" ] "Use `database.postgres.name` instead.")
      (assertRemovedOption [
        "settings"
        "db_password_file"
      ] "Use `database.postgres.password_file` instead.")
      (assertRemovedOption [ "settings" "db_path" ] "Use `database.sqlite.path` instead.")
      (assertRemovedOption [ "settings" "db_port" ] "Use `database.postgres.port` instead.")
      (assertRemovedOption [ "settings" "db_type" ] "Use `database.type` instead.")
      (assertRemovedOption [ "settings" "db_user" ] "Use `database.postgres.user` instead.")
      (assertRemovedOption [ "settings" "dns_config" ] "Use `dns` instead.")
      (assertRemovedOption [ "settings" "dns_config" "domains" ] "Use `dns.search_domains` instead.")
      (assertRemovedOption [
        "settings"
        "dns_config"
        "nameservers"
      ] "Use `dns.nameservers.global` instead.")
      (assertRemovedOption [
        "settings"
        "oidc"
        "strip_email_domain"
      ] "The strip_email_domain option got removed upstream")
    ];

    environment = {
      # Headscale CLI needs a minimal config to be able to locate the unix socket
      # to talk to the server instance.
      etc."headscale/config.yaml".source = settingsFormat.generate "headscale.yaml" cliConfig;
      systemPackages = [ cfg.package ];
    };

    services.headscale.settings = lib.mkMerge [
      cliConfig
      {
        listen_addr = lib.mkDefault "${cfg.address}:${toString cfg.port}";
        tls_letsencrypt_cache_dir = "${dataDir}/.cache";
      }
    ];

    systemd.services.headscale = {
      after = [ "network-online.target" ];
      description = "headscale coordination server for Tailscale";

      script = ''
        ${lib.optionalString (cfg.settings.database.postgres.password_file != null) ''
          export HEADSCALE_DATABASE_POSTGRES_PASS="$(head -n1 ${lib.escapeShellArg cfg.settings.database.postgres.password_file})"
        ''}

        exec ${lib.getExe cfg.package} serve --config ${cfg.configFile}
      '';

      serviceConfig =
        let
          capabilityBoundingSet = [ "CAP_CHOWN" ] ++ lib.optional (cfg.port < 1024) "CAP_NET_BIND_SERVICE";
        in
        {
          AmbientCapabilities = capabilityBoundingSet;
          CapabilityBoundingSet = capabilityBoundingSet;
          Group = cfg.group;
          LockPersonality = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateTmp = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RemoveIPC = true;
          Restart = "always";
          RestartSec = "5s";
          RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          # Hardening options
          RuntimeDirectory = "headscale";
          # Allow headscale group access so users can be added and use the CLI.
          RuntimeDirectoryMode = "0750";
          StateDirectory = "headscale";
          StateDirectoryMode = "0750";
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
            "@chown"
          ];

          Type = "simple";
          UMask = "0077";
          User = cfg.user;
        };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    users.groups.headscale = lib.mkIf (cfg.group == "headscale") { };

    users.users.headscale = lib.mkIf (cfg.user == "headscale") {
      description = "headscale user";
      group = cfg.group;
      home = dataDir;
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [
    kradalby
    misterio77
  ];
}
