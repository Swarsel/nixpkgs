{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.portunus;

in
{
  options.services.portunus = {
    enable = lib.mkEnableOption "Portunus, a self-contained user/group management and authentication service for LDAP";
    package = lib.mkPackageOption pkgs "portunus" { };

    dex = {
      enable = lib.mkEnableOption ''
        Dex ldap connector.

        To activate dex, first a search user must be created in the Portunus web ui
        and then the password must to be set as the `DEX_SEARCH_USER_PASSWORD` environment variable
        in the [](#opt-services.dex.environmentFile) setting
      '';

      oidcClients = lib.mkOption {
        default = [ ];

        description = ''
          List of OIDC clients.

          The OIDC secret must be set as the `DEX_CLIENT_''${id}` environment variable
          in the [](#opt-services.dex.environmentFile) setting.

          ::: {.note}
          Make sure the id only contains characters that are allowed in an environment variable name, e.g. no -.
          :::
        '';

        example = [
          {
            callbackURL = "https://example.com/client/oidc/callback";
            id = "service";
          }
        ];

        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              callbackURL = lib.mkOption {
                description = "URL where the OIDC client should redirect";
                type = lib.types.str;
              };

              id = lib.mkOption {
                description = "ID of the OIDC client";
                type = lib.types.str;
              };
            };
          }
        );
      };

      port = lib.mkOption {
        default = 5556;
        description = "Port where dex should listen on.";
        type = lib.types.port;
      };
    };

    domain = lib.mkOption {
      description = "Subdomain which gets reverse proxied to Portunus webserver.";
      example = "sso.example.com";
      type = lib.types.str;
    };

    group = lib.mkOption {
      default = "portunus";
      description = "Group account under which Portunus runs its webserver.";
      type = lib.types.str;
    };

    ldap = {
      package = lib.mkPackageOption pkgs "openldap" { };

      group = lib.mkOption {
        default = "openldap";
        description = "Group account under which Portunus runs its LDAP server.";
        type = lib.types.str;
      };

      searchUserName = lib.mkOption {
        default = "";

        description = ''
          The login name of the search user.
          This user account must be configured in Portunus either manually or via seeding.
        '';

        example = "admin";
        type = lib.types.str;
      };

      suffix = lib.mkOption {
        description = ''
          The DN of the topmost entry in your LDAP directory.
          Please refer to the Portunus documentation for more information on how this impacts the structure of the LDAP directory.
        '';

        example = "dc=example,dc=org";
        type = lib.types.str;
      };

      tls = lib.mkOption {
        default = false;

        description = ''
          Whether to enable LDAPS protocol.
          This also adds two entries to the `/etc/hosts` file to point [](#opt-services.portunus.domain) to localhost,
          so that CLIs and programs can use ldaps protocol and verify the certificate without opening the firewall port for the protocol.

          This requires a TLS certificate for [](#opt-services.portunus.domain) to be configured via [](#opt-security.acme.certs).
        '';

        type = lib.types.bool;
      };

      user = lib.mkOption {
        default = "openldap";
        description = "User account under which Portunus runs its LDAP server.";
        type = lib.types.str;
      };
    };

    port = lib.mkOption {
      default = 8080;

      description = ''
        Port where the Portunus webserver should listen on.

        This must be put behind a TLS-capable reverse proxy because Portunus only listens on localhost.
      '';

      type = lib.types.port;
    };

    seedPath = lib.mkOption {
      default = null;

      description = ''
        Path to a portunus seed file in json format.
        See <https://github.com/majewsky/portunus#seeding-users-and-groups-from-static-configuration> for available options.
      '';

      type = lib.types.nullOr lib.types.path;
    };

    seedSettings = lib.mkOption {
      default = null;

      description = ''
        Seed settings for users and groups.
        See upstream for format <https://github.com/majewsky/portunus#seeding-users-and-groups-from-static-configuration>
      '';

      type = with lib.types; nullOr (attrsOf (listOf (attrsOf anything)));
    };

    stateDir = lib.mkOption {
      default = "/var/lib/portunus";
      description = "Path where Portunus stores its state.";
      type = lib.types.path;
    };

    user = lib.mkOption {
      default = "portunus";
      description = "User account under which Portunus runs its webserver.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.dex.enable -> cfg.ldap.searchUserName != "";
        message = "services.portunus.dex.enable requires services.portunus.ldap.searchUserName to be set.";
      }
    ];

    # add ldapsearch(1) etc. to interactive shells
    environment.systemPackages = [ cfg.ldap.package ];

    # allow connecting via ldaps /w certificate without opening ports
    networking.hosts = lib.mkIf cfg.ldap.tls {
      "127.0.0.1" = [ cfg.domain ];
      "::1" = [ cfg.domain ];
    };

    services = {
      dex = lib.mkIf cfg.dex.enable {
        enable = true;

        settings = {
          connectors = [
            {
              config = {
                bindDN = "uid=${cfg.ldap.searchUserName},ou=users,${cfg.ldap.suffix}";
                bindPW = "$DEX_SEARCH_USER_PASSWORD";

                groupSearch = {
                  baseDN = "ou=groups,${cfg.ldap.suffix}";
                  filter = "(objectclass=groupOfNames)";
                  nameAttr = "cn";

                  userMatchers = [
                    {
                      groupAttr = "member";
                      userAttr = "DN";
                    }
                  ];
                };

                host = "${cfg.domain}:636";

                userSearch = {
                  baseDN = "ou=users,${cfg.ldap.suffix}";
                  emailAttr = "mail";
                  filter = "(objectclass=person)";
                  idAttr = "uid";
                  nameAttr = "cn";
                  preferredUsernameAttr = "uid";
                  username = "uid";
                };
              };

              id = "ldap";
              name = "LDAP";
              type = "ldap";
            }
          ];

          enablePasswordDB = false;
          issuer = "https://${cfg.domain}/dex";

          staticClients = lib.forEach cfg.dex.oidcClients (client: {
            inherit (client) id;
            name = "OIDC for ${client.id}";
            redirectURIs = [ client.callbackURL ];
            secretEnv = "DEX_CLIENT_${client.id}";
          });

          storage = {
            config.file = "/var/lib/dex/dex.db";
            type = "sqlite3";
          };

          web.http = "127.0.0.1:${toString cfg.dex.port}";
        };
      };

      portunus.seedPath = lib.mkIf (cfg.seedSettings != null) (
        pkgs.writeText "seed.json" (builtins.toJSON cfg.seedSettings)
      );
    };

    systemd.services = {
      dex = lib.mkIf cfg.dex.enable {
        serviceConfig = {
          # `dex.service` is super locked down out of the box, but we need some
          # place to write the SQLite database. This creates $STATE_DIRECTORY below
          # /var/lib/private because DynamicUser=true, but it gets symlinked into
          # /var/lib/dex inside the unit
          StateDirectory = "dex";
        };
      };

      portunus = {
        after = [ "network.target" ];
        description = "Self-contained authentication service";

        environment = {
          PORTUNUS_LDAP_SUFFIX = cfg.ldap.suffix;
          PORTUNUS_SERVER_BINARY = "${cfg.package}/bin/portunus-server";
          PORTUNUS_SERVER_GROUP = cfg.group;
          PORTUNUS_SERVER_HTTP_LISTEN = "127.0.0.1:${toString cfg.port}";
          PORTUNUS_SERVER_STATE_DIR = cfg.stateDir;
          PORTUNUS_SERVER_USER = cfg.user;
          PORTUNUS_SLAPD_BINARY = "${cfg.ldap.package}/libexec/slapd";
          PORTUNUS_SLAPD_GROUP = cfg.ldap.group;
          PORTUNUS_SLAPD_SCHEMA_DIR = "${cfg.ldap.package}/etc/schema";
          PORTUNUS_SLAPD_USER = cfg.ldap.user;
        }
        // (lib.optionalAttrs (cfg.seedPath != null) {
          PORTUNUS_SEED_PATH = cfg.seedPath;
        })
        // (lib.optionalAttrs cfg.ldap.tls (
          let
            acmeDirectory = config.security.acme.certs."${cfg.domain}".directory;
          in
          {
            PORTUNUS_SERVER_HTTP_SECURE = "true";
            PORTUNUS_SLAPD_TLS_CA_CERTIFICATE = config.security.pki.caBundle;
            PORTUNUS_SLAPD_TLS_CERTIFICATE = "${acmeDirectory}/cert.pem";
            PORTUNUS_SLAPD_TLS_DOMAIN_NAME = cfg.domain;
            PORTUNUS_SLAPD_TLS_PRIVATE_KEY = "${acmeDirectory}/key.pem";
          }
        ));

        serviceConfig = {
          ExecStart = "${cfg.package}/bin/portunus-orchestrator";
          Restart = "on-failure";
        };

        wantedBy = [ "multi-user.target" ];
      };
    };

    users.groups = lib.mkMerge [
      (lib.mkIf (cfg.ldap.user == "openldap") {
        openldap = { };
      })
      (lib.mkIf (cfg.user == "portunus") {
        portunus = { };
      })
    ];

    users.users = lib.mkMerge [
      (lib.mkIf (cfg.ldap.user == "openldap") {
        openldap = {
          group = cfg.ldap.group;
          isSystemUser = true;
        };
      })
      (lib.mkIf (cfg.user == "portunus") {
        portunus = {
          group = cfg.group;
          isSystemUser = true;
        };
      })
    ];
  };

  meta.maintainers = pkgs.portunus.meta.maintainers;
}
