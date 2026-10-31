{
  lib,
  pkgs,
  config,
  utils,
  ...
}:
let
  inherit (lib)
    attrNames
    boolToString
    concatLines
    concatLists
    elem
    filterAttrs
    flip
    forEach
    getExe
    hasInfix
    isBool
    mapAttrs
    mapAttrsToList
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkPackageOption
    mkRemovedOptionModule
    mkRenamedOptionModule
    optional
    optionalString
    stringLength
    toInt
    types
    ;

  cfg = config.services.firezone.server;
  jsonFormat = pkgs.formats.json { };

  typePortRange =
    types.coercedTo types.port
      (x: {
        from = x;
        to = x;
      })
      (
        types.submodule {
          options = {
            from = mkOption {
              type = types.port;
              description = "The start of the port range, inclusive.";
            };

            to = mkOption {
              type = types.port;
              description = "The end of the port range, inclusive.";
            };
          };
        }
      );

  # Splits an external URL into its domain and location (path)
  urlComponents =
    url:
    let
      m = builtins.match "https://([^/]*)(/.*)" url;
    in
    {
      domain = builtins.elemAt m 0;
      location = builtins.elemAt m 1;
    };
  webUrl = urlComponents cfg.web.externalUrl;
  apiUrl = urlComponents cfg.api.externalUrl;

  # The listen address of the portal in a form that can be used in URLs
  listenHost =
    if hasInfix ":" cfg.portal.address then "[${cfg.portal.address}]" else cfg.portal.address;
  # A loopback address is required to reach the portal when it listens on a wildcard address
  localHost =
    if cfg.portal.address == "0.0.0.0" then
      "127.0.0.1"
    else if cfg.portal.address == "::" then
      "[::1]"
    else
      listenHost;

  # All non-secret environment variables for the portal
  portalEnvironment = mapAttrs (_: v: if isBool v then boolToString v else toString v) cfg.settings;

  # All mandatory secrets which were not explicitly provided by the user will
  # have to be generated, if they do not yet exist.
  generateSecrets =
    let
      requiredSecrets = filterAttrs (_: v: v == null) cfg.settingsSecret;
    in
    ''
      mkdir -p secrets
      chmod 700 secrets
    ''
    + concatLines (
      forEach (attrNames requiredSecrets) (secret: ''
        if [[ ! -e secrets/${secret} ]]; then
          echo "Generating ${secret}"
          # Some secrets like TOKENS_KEY_BASE require a value >=64 bytes.
          head -c 64 /dev/urandom | base64 -w 0 > secrets/${secret}
          chmod 600 secrets/${secret}
        fi
      '')
    );

  # All secrets given in `cfg.settingsSecret` must be loaded from a file and
  # exported into the environment.
  loadSecretEnvironment = concatLines (
    forEach (attrNames cfg.settingsSecret) (
      secret:
      "export ${secret}=$(< ${
        if cfg.settingsSecret.${secret} == null then
          "secrets/${secret}"
        else
          "\"$CREDENTIALS_DIRECTORY/${secret}\""
      })"
    )
  );

  secretsReplacement = utils.genJqSecretsReplacement {
    loadCredential = true;
  } cfg.provision "/run/firezone/provision.json";

  commonServiceConfig = {
    AmbientCapabilities = [ ];
    CapabilityBoundingSet = [ ];
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    NoNewPrivileges = true;
    PrivateMounts = true;
    PrivateTmp = true;
    PrivateUsers = false;
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
    RestrictAddressFamilies = [
      "AF_INET"
      "AF_INET6"
      "AF_NETLINK"
      "AF_UNIX"
    ];
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = "@system-service";
    UMask = "077";

    DynamicUser = true;
    User = "firezone";

    StateDirectory = "firezone";
    WorkingDirectory = "/var/lib/firezone";
    RuntimeDirectory = "firezone";

    LoadCredential = mapAttrsToList (secretName: secretFile: "${secretName}:${secretFile}") (
      filterAttrs (_: v: v != null) cfg.settingsSecret
    );
    Type = "exec";
    Restart = "on-failure";
    RestartSec = 10;
  };

  mkSecretOption =
    description:
    mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        ${description}

        If this is `null`, a value will automatically be generated on
        startup. You do not need to set this except when you spread your
        cluster over multiple hosts.
      '';
    };

  componentRemoved =
    component:
    "The ${component} component has been merged into the portal, which is now a single release. Use services.firezone.server.enable, services.firezone.server.package and services.firezone.server.settings instead.";
in
{
  imports = [
    (mkRemovedOptionModule [ "services" "firezone" "server" "domain" "enable" ] (
      componentRemoved "domain"
    ))
    (mkRemovedOptionModule [ "services" "firezone" "server" "domain" "package" ] (
      componentRemoved "domain"
    ))
    (mkRenamedOptionModule
      [ "services" "firezone" "server" "domain" "settings" ]
      [ "services" "firezone" "server" "settings" ]
    )

    (mkRemovedOptionModule [ "services" "firezone" "server" "web" "enable" ] (componentRemoved "web"))
    (mkRemovedOptionModule [ "services" "firezone" "server" "web" "package" ] (componentRemoved "web"))
    (mkRenamedOptionModule
      [ "services" "firezone" "server" "web" "settings" ]
      [ "services" "firezone" "server" "settings" ]
    )
    (mkRenamedOptionModule
      [ "services" "firezone" "server" "web" "address" ]
      [ "services" "firezone" "server" "portal" "address" ]
    )
    (mkRenamedOptionModule
      [ "services" "firezone" "server" "web" "port" ]
      [ "services" "firezone" "server" "portal" "port" ]
    )
    (mkRenamedOptionModule
      [ "services" "firezone" "server" "web" "trustedProxies" ]
      [ "services" "firezone" "server" "portal" "trustedProxies" ]
    )

    (mkRemovedOptionModule [ "services" "firezone" "server" "api" "enable" ] (componentRemoved "api"))
    (mkRemovedOptionModule [ "services" "firezone" "server" "api" "package" ] (componentRemoved "api"))
    (mkRenamedOptionModule
      [ "services" "firezone" "server" "api" "settings" ]
      [ "services" "firezone" "server" "settings" ]
    )
    (mkRenamedOptionModule
      [ "services" "firezone" "server" "api" "address" ]
      [ "services" "firezone" "server" "portal" "address" ]
    )
    (mkRemovedOptionModule [ "services" "firezone" "server" "api" "port" ] ''
      The portal now serves the web UI and the API from a single listener which
      is configured via services.firezone.server.portal.port. Requests are
      dispatched based on the hostnames of services.firezone.server.web.externalUrl
      and services.firezone.server.api.externalUrl.
    '')
    (mkRenamedOptionModule
      [ "services" "firezone" "server" "api" "trustedProxies" ]
      [ "services" "firezone" "server" "portal" "trustedProxies" ]
    )
  ];

  options.services.firezone.server = {
    enable = mkEnableOption "the Firezone portal server";
    enableLocalDB = mkEnableOption "a local postgresql database for Firezone";
    nginx.enable = mkEnableOption "nginx virtualhost definitions for the web UI and the API";

    package = mkPackageOption pkgs "firezone-server" { };

    openClusterFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Opens up the erlang distribution port of the portal to allow reaching
        the server cluster from the internet. You only need to set this if you
        are actually distributing your cluster across multiple machines.
      '';
    };

    clusterHosts = mkOption {
      type = types.listOf types.str;
      default = [
        "portal@localhost.localdomain"
      ];
      description = ''
        A list of nodes that are part of this cluster. For a single-machine
        setup, the default value will be sufficient. This value will
        automatically set `ERLANG_CLUSTER_ADAPTER_CONFIG`.

        The format is `<NODE_NAME>@<HOSTNAME>`.
      '';
    };

    settingsSecret = mkOption {
      default = { };
      description = ''
        This is a convenience option which allows you to set secret values for
        environment variables by specifying a file which will contain the value
        at runtime. Before starting the server, the content of each file will
        be loaded into the respective environment variable.

        Otherwise, this option is equivalent to
        {option}`services.firezone.server.settings`. Refer to the settings
        option for more information regarding the actual variables.
      '';
      type = types.submodule {
        freeformType = types.attrsOf types.path;
        options = {
          RELEASE_COOKIE = mkSecretOption ''
            A file containing a unique secret identifier for the Erlang
            cluster. The Firezone portal in your cluster must use the same
            value across all instances.
          '';

          TOKENS_KEY_BASE = mkSecretOption ''
            A file containing a unique base64 encoded secret for the
            `TOKENS_KEY_BASE`. The Firezone portal in your cluster must use
            the same value across all instances.
          '';

          TOKENS_SALT = mkSecretOption ''
            A file containing a unique base64 encoded secret for the
            `TOKENS_SALT`. The Firezone portal in your cluster must use the
            same value across all instances.
          '';

          SECRET_KEY_BASE = mkSecretOption ''
            A file containing a unique base64 encoded secret for the
            `SECRET_KEY_BASE`. The Firezone portal in your cluster must use
            the same value across all instances.
          '';

          LIVE_VIEW_SIGNING_SALT = mkSecretOption ''
            A file containing a unique base64 encoded secret for the
            `LIVE_VIEW_SIGNING_SALT`. The Firezone portal in your cluster must
            use the same value across all instances.
          '';

          COOKIE_SIGNING_SALT = mkSecretOption ''
            A file containing a unique base64 encoded secret for the
            `COOKIE_SIGNING_SALT`. The Firezone portal in your cluster must
            use the same value across all instances.
          '';

          COOKIE_ENCRYPTION_SALT = mkSecretOption ''
            A file containing a unique base64 encoded secret for the
            `COOKIE_ENCRYPTION_SALT`. The Firezone portal in your cluster must
            use the same value across all instances.
          '';

          OPS_SECRET_KEY_BASE = mkSecretOption ''
            A file containing a unique base64 encoded secret for the
            `OPS_SECRET_KEY_BASE` of the internal ops endpoint. This must be
            different from `SECRET_KEY_BASE`. The Firezone portal in your
            cluster must use the same value across all instances.
          '';

          OPS_LIVE_VIEW_SIGNING_SALT = mkSecretOption ''
            A file containing a unique base64 encoded secret for the
            `OPS_LIVE_VIEW_SIGNING_SALT` of the internal ops endpoint. The
            Firezone portal in your cluster must use the same value across all
            instances.
          '';

          OPS_COOKIE_SIGNING_SALT = mkSecretOption ''
            A file containing a unique base64 encoded secret for the
            `OPS_COOKIE_SIGNING_SALT` of the internal ops endpoint. The
            Firezone portal in your cluster must use the same value across all
            instances.
          '';

          OPS_ADMIN_PASSWORD = mkSecretOption ''
            A file containing the password for HTTP basic authentication on
            the internal ops endpoint. The corresponding username is
            configured via `OPS_ADMIN_USERNAME` in
            {option}`services.firezone.server.settings`.
          '';
        };
      };
    };

    settings = mkOption {
      description = ''
        Environment variables for the Firezone portal server. For a list of available
        variables, please refer to the [upstream definitions](https://github.com/firezone/firezone/blob/main/elixir/lib/portal/config/definitions.ex).
        Some variables like `OUTBOUND_EMAIL_ADAPTER_OPTS` require json values
        for which you can use `VAR = builtins.toJSON { /* ... */ }`.
      '';
      default = { };
      type = types.submodule {
        freeformType = types.attrsOf (
          types.oneOf [
            types.bool
            types.float
            types.int
            types.str
            types.path
            types.package
          ]
        );
      };
    };

    smtp = {
      configureManually = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Outbound email configuration is mandatory for Firezone and supports
          many different delivery adapters. Yet, most users will only need an
          SMTP relay to send emails, so this configuration enforced by default.

          If you want to utilize an alternative way to send emails (e.g. via a
          supportd API-based service), enable this option and define
          `OUTBOUND_EMAIL_FROM`, `OUTBOUND_EMAIL_ADAPTER` and
          `OUTBOUND_EMAIL_ADAPTER_OPTS` manually via
          {option}`services.firezone.server.settings` and/or
          {option}`services.firezone.server.settingsSecret`.

          The Firezone documentation holds [a list of supported Swoosh adapters](https://github.com/firezone/firezone/blob/main/website/src/app/docs/reference/env-vars/readme.mdx#outbound-emails).
        '';
      };

      from = mkOption {
        type = types.str;
        example = "firezone@example.com";
        description = "Outbound SMTP FROM address";
      };

      host = mkOption {
        type = types.str;
        example = "mail.example.com";
        description = "Outbound SMTP host";
      };

      port = mkOption {
        type = types.port;
        example = 465;
        description = "Outbound SMTP port";
      };

      implicitTls = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to use implicit TLS instead of STARTTLS (usually port 465)";
      };

      username = mkOption {
        type = types.str;
        example = "firezone@example.com";
        description = "Username to authenticate against the SMTP relay";
      };

      passwordFile = mkOption {
        type = types.path;
        example = "/run/secrets/smtp-password";
        description = "File containing the password for the given username. Beware that a file in the nix store will be world readable.";
      };
    };

    web.externalUrl = mkOption {
      type = types.strMatching "^https://.+/$";
      example = "https://firezone.example.com/";
      description = ''
        The external URL under which you will serve the Firezone web UI. You
        need to setup a reverse proxy for TLS termination, either with
        {option}`services.firezone.server.nginx.enable` or manually.

        The portal dispatches requests to the web UI and the API based on
        the hostname, so this must use a different hostname than
        {option}`services.firezone.server.api.externalUrl`.
      '';
    };

    api.externalUrl = mkOption {
      type = types.strMatching "^https://.+/$";
      example = "https://api.firezone.example.com/";
      description = ''
        The external URL under which you will serve the Firezone API, which
        is used by relays, gateways and clients to connect to the portal. You
        need to setup a reverse proxy for TLS termination, either with
        {option}`services.firezone.server.nginx.enable` or manually.

        The portal dispatches requests to the web UI and the API based on
        the hostname, so this must use a different hostname than
        {option}`services.firezone.server.web.externalUrl`.
      '';
    };

    portal = {
      address = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "The address to listen on";
      };

      port = mkOption {
        type = types.port;
        default = 8080;
        description = ''
          The port under which the Firezone portal will serve both the web UI
          and the API. Requests are dispatched based on the hostnames of
          {option}`services.firezone.server.web.externalUrl` and
          {option}`services.firezone.server.api.externalUrl`.
        '';
      };

      trustedProxies = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [
          "127.0.0.1"
          "::1"
        ];
        description = ''
          A list of trusted proxies (IP addresses or CIDRs). Forwarded headers
          like `X-Forwarded-For` are only honored for requests originating from
          these addresses. The local nginx reverse proxy is automatically
          trusted when {option}`services.firezone.server.nginx.enable` is set.
        '';
      };
    };

    provision = {
      enable = mkEnableOption "provisioning of the Firezone portal";
      accounts = mkOption {
        type = types.attrsOf (
          types.submodule {
            freeformType = jsonFormat.type;
            options = {
              name = mkOption {
                type = types.str;
                description = "The account name";
                example = "My Organization";
              };

              features =
                let
                  mkFeatureOption =
                    name: default:
                    mkOption {
                      type = types.bool;
                      inherit default;
                      description = "Whether to enable the `${name}` feature for this account.";
                    };
                in
                {
                  policy_conditions = mkFeatureOption "policy_conditions" true;
                  idp_sync = mkFeatureOption "idp_sync" true;
                  internet_resource = mkFeatureOption "internet_resource" true;
                  device_posture = mkFeatureOption "device_posture" true;
                  log_sinks = mkFeatureOption "log_sinks" true;
                  slug_changes = mkFeatureOption "slug_changes" true;
                  iceless = mkFeatureOption "iceless" false;
                };

              actors = mkOption {
                type = types.attrsOf (
                  types.submodule {
                    options = {
                      type = mkOption {
                        type = types.enum [
                          "account_admin_user"
                          "account_user"
                          "service_account"
                          "api_client"
                        ];
                        description = "The account type";
                      };

                      name = mkOption {
                        type = types.str;
                        description = "The name of this actor";
                      };

                      email = mkOption {
                        type = types.nullOr types.str;
                        default = null;
                        description = ''
                          The email address used to authenticate as this actor.
                          Required for `account_user` and `account_admin_user` actors,
                          must be `null` for `service_account` and `api_client` actors.
                        '';
                      };

                      passwordHash = mkOption {
                        type = types.nullOr types.str;
                        default = null;
                        description = ''
                          An Argon2 password hash for this actor. This enables the actor to
                          sign in via the "Username & Password" authentication provider
                          using their email and password. Without a password, users can
                          only sign in via email one-time passcodes or a provisioned OIDC
                          provider.

                          Generate a hash using: `nix-shell -p libargon2 --run 'echo -n "your-password" | argon2 "$(head -c 16 /dev/urandom | base64)" -id -e'`
                        '';
                      };
                    };
                  }
                );
                default = { };
                example = {
                  admin = {
                    type = "account_admin_user";
                    name = "Admin";
                    email = "admin@myorg.example.com";
                    passwordHash = "$argon2id$v=19$m=65536,t=3,p=4$...";
                  };
                };
                description = ''
                  All actors (users) to provision. The attribute name will only
                  be used to track the actor and does not have any significance
                  for Firezone.
                '';
              };

              auth = mkOption {
                type = types.attrsOf (
                  types.submodule {
                    options = {
                      name = mkOption {
                        type = types.str;
                        description = "The name of this authentication provider.";
                      };

                      adapter = mkOption {
                        type = types.enum [ "oidc" ];
                        description = ''
                          The auth adapter type. Currently only `oidc` is supported
                          for provisioning. Specialized providers (Google, Entra,
                          Okta, GitHub) should be configured through the web UI.
                        '';
                      };

                      adapter_config = mkOption {
                        type = types.submodule {
                          freeformType = jsonFormat.type;
                          options = {
                            issuer = mkOption {
                              type = types.str;
                              description = "The OIDC issuer URL";
                            };

                            client_id = mkOption {
                              type = types.str;
                              description = "The OIDC client id";
                            };

                            client_secret = mkOption {
                              type = jsonFormat.type;
                              example = {
                                _secret = "/run/secrets/oidc-client-secret";
                              };
                              description = ''
                                The OIDC client secret. Use `{ _secret = "/path/to/file"; }`
                                to load the secret from a file at runtime instead of
                                storing it in the nix store.
                              '';
                            };

                            discovery_document_uri = mkOption {
                              type = types.str;
                              description = "The OIDC discovery document URI";
                            };

                            context = mkOption {
                              type = types.enum [
                                "clients_and_portal"
                                "clients_only"
                                "portal_only"
                              ];
                              default = "clients_and_portal";
                              description = "Where this provider can be used to sign in.";
                            };
                          };
                        };
                        default = { };
                        description = ''
                          Adapter-specific configuration. Optionally,
                          `client_session_lifetime_secs` and
                          `portal_session_lifetime_secs` can be set to limit the
                          session lifetimes.
                        '';
                      };
                    };
                  }
                );
                default = { };
                example = {
                  myoidcprovider = {
                    name = "My OIDC Provider";
                    adapter = "oidc";
                    adapter_config = {
                      issuer = "https://auth.example.com";
                      client_id = "my-client-id";
                      client_secret._secret = "/run/secrets/oidc-client-secret";
                      discovery_document_uri = "https://auth.example.com/.well-known/openid-configuration";
                    };
                  };
                };
                description = ''
                  All authentication providers to provision. The attribute name
                  will only be used to track the provider and does not have any
                  significance for Firezone.
                '';
              };

              resources = mkOption {
                type = types.attrsOf (
                  types.submodule {
                    options = {
                      type = mkOption {
                        type = types.enum [
                          "dns"
                          "cidr"
                          "ip"
                        ];
                        description = "The resource type";
                      };

                      name = mkOption {
                        type = types.str;
                        description = "The name of this resource";
                      };

                      address = mkOption {
                        type = types.str;
                        description = "The address of this resource. Depending on the resource type, this should be an ip, ip with cidr mask or a domain.";
                      };

                      addressDescription = mkOption {
                        type = types.nullOr types.str;
                        default = null;
                        description = "An optional description for resource address, usually a full link to the resource including a schema.";
                      };

                      gatewayGroups = mkOption {
                        type = types.nonEmptyListOf types.str;
                        description = ''
                          The gateway group (site) which can reach the resource and may be
                          used to connect to it. Firezone no longer supports multiple sites
                          per resource, so only the first entry is used.
                        '';
                      };

                      filters = mkOption {
                        type = types.listOf (
                          types.submodule {
                            options = {
                              protocol = mkOption {
                                type = types.enum [
                                  "icmp"
                                  "tcp"
                                  "udp"
                                ];
                                description = "The protocol to allow";
                              };

                              ports = mkOption {
                                type = types.listOf typePortRange;
                                example = [
                                  443
                                  {
                                    from = 8080;
                                    to = 8100;
                                  }
                                ];
                                default = [ ];
                                apply =
                                  xs: map (x: if x.from == x.to then toString x.from else "${toString x.from} - ${toString x.to}") xs;
                                description = "Either a single port or port range to allow. Both bounds are inclusive.";
                              };
                            };
                          }
                        );
                        default = [ ];
                        description = "A list of filter to restrict traffic. If no filters are given, all traffic is allowed.";
                      };
                    };
                  }
                );
                default = { };
                example = {
                  vaultwarden = {
                    type = "dns";
                    name = "Vaultwarden";
                    address = "vault.example.com";
                    addressDescription = "https://vault.example.com";
                    gatewayGroups = [ "my-site" ];
                    filters = [
                      { protocol = "icmp"; }
                      {
                        protocol = "tcp";
                        ports = [
                          80
                          443
                        ];
                      }
                    ];
                  };
                };
                description = ''
                  All resources to provision. The attribute name will only be used to
                  track the resource and does not have any significance for Firezone.
                '';
              };

              policies = mkOption {
                type = types.attrsOf (
                  types.submodule {
                    options = {
                      description = mkOption {
                        type = types.nullOr types.str;
                        default = null;
                        description = "The description of this policy";
                      };

                      group = mkOption {
                        type = types.str;
                        description = ''
                          The group which should be allowed access to the given resource.
                          Use `everyone` to refer to the managed group containing all users
                          of this account.
                        '';
                      };

                      resource = mkOption {
                        type = types.str;
                        description = "The resource to which access should be allowed.";
                      };
                    };
                  }
                );
                default = { };
                example = {
                  access_vaultwarden = {
                    description = "Allow anyone to access vaultwarden";
                    group = "everyone";
                    resource = "vaultwarden";
                  };
                };
                description = ''
                  All policies to provision. The attribute name will only be used to
                  track the policy and does not have any significance for Firezone.
                '';
              };

              groups = mkOption {
                type = types.attrsOf (
                  types.submodule {
                    options = {
                      name = mkOption {
                        type = types.str;
                        description = "The name of this group";
                      };

                      members = mkOption {
                        type = types.listOf types.str;
                        default = [ ];
                        description = "The members of this group, referring to the attribute names of provisioned actors.";
                      };

                      forceMembers = mkOption {
                        type = types.bool;
                        default = false;
                        description = "Ensure that only the given members are part of this group at every server start.";
                      };
                    };
                  }
                );
                default = { };
                example = {
                  users = {
                    name = "Users";
                  };
                };
                description = ''
                  All groups to provision. The attribute name will only be used
                  to track the group and does not have any significance for
                  Firezone.

                  A managed group named `Everyone` is automatically created for
                  each account and can be referred to as `everyone` in policies.
                  Service accounts are not part of this group.
                '';
              };

              gatewayGroups = mkOption {
                type = types.attrsOf (
                  types.submodule {
                    options = {
                      name = mkOption {
                        type = types.str;
                        description = "The name of this gateway group";
                      };
                    };
                  }
                );
                default = { };
                example = {
                  my-gateways = {
                    name = "My Gateways";
                  };
                };
                description = ''
                  All gateway groups (sites) to provision. The attribute name
                  will only be used to track the gateway group and does not have any
                  significance for Firezone.
                '';
              };
            };
          }
        );
        default = { };
        example = {
          main = {
            name = "My Account / Organization";
            metadata.stripe.billing_email = "org@myorg.example.com";
            features.idp_sync = false;
          };
        };
        description = ''
          All accounts to provision. The attribute name specified here will
          become the account slug. By using `{ _secret = "/path/to/file"; }` as
          a value anywhere in these settings, the provisioning script will
          replace that value with the content of the given file at runtime.

          Provisioned entities are tracked by their attribute names in
          `/var/lib/firezone/provision-uuids.json`, so renaming an attribute
          removes the entity and creates a new one. Existing entities which are
          not tracked yet but match a provisioned one by a unique property
          (account slug, actor email, OIDC client id, site/group/resource name,
          policy group and resource) are adopted instead of being recreated.

          Please refer to the [Firezone source code](https://github.com/firezone/firezone/blob/main/elixir/lib/portal/account.ex)
          for all available properties.
        '';
      };
    };
  };

  config = mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.enable || webUrl.domain != apiUrl.domain;
          message = ''
            services.firezone.server.web.externalUrl and services.firezone.server.api.externalUrl
            must use different hostnames, as the portal dispatches requests based on the hostname.
          '';
        }
      ]
      ++ concatLists (
        flip mapAttrsToList cfg.provision.accounts (
          accountName: accountCfg:
          [
            {
              assertion =
                (builtins.match "^[[:lower:][:digit:]_-]+$" accountName) != null && stringLength accountName >= 3;
              message = "The account name '${accountName}' must consist of at least 3 lowercase characters, digits, underscores or dashes, as it will be used as the URL slug for this account.";
            }
          ]
          ++ flip mapAttrsToList accountCfg.actors (
            actorName: actorCfg: {
              assertion =
                if
                  elem actorCfg.type [
                    "account_user"
                    "account_admin_user"
                  ]
                then
                  actorCfg.email != null
                else
                  actorCfg.email == null && actorCfg.passwordHash == null;
              message = "Actor '${actorName}' in account '${accountName}' has type '${actorCfg.type}', which ${
                if
                  elem actorCfg.type [
                    "account_user"
                    "account_admin_user"
                  ]
                then
                  "requires an email address"
                else
                  "must not have an email address or password"
              }.";
            }
          )
          ++ flip mapAttrsToList accountCfg.auth (
            authName: _: {
              assertion = (builtins.match "^[[:alnum:]_-]+$" authName) != null;
              message = "The authentication provider attribute key '${authName}' in account '${accountName}' must contain only letters, numbers, underscores or dashes.";
            }
          )
          ++ flip mapAttrsToList accountCfg.groups (
            groupName: groupCfg: {
              assertion = builtins.all (member: accountCfg.actors ? ${member}) groupCfg.members;
              message = "Group '${groupName}' in account '${accountName}' refers to members which are not provisioned actors of this account.";
            }
          )
          ++ flip mapAttrsToList accountCfg.resources (
            resourceName: resourceCfg: {
              assertion = builtins.all (
                gatewayGroup: accountCfg.gatewayGroups ? ${gatewayGroup}
              ) resourceCfg.gatewayGroups;
              message = "Resource '${resourceName}' in account '${accountName}' refers to gateway groups which are not provisioned in this account.";
            }
          )
          ++ flip mapAttrsToList accountCfg.policies (
            policyName: policyCfg: {
              assertion =
                (policyCfg.group == "everyone" || accountCfg.groups ? ${policyCfg.group})
                && accountCfg.resources ? ${policyCfg.resource};
              message = "Policy '${policyName}' in account '${accountName}' refers to a group or resource which is not provisioned in this account.";
            }
          )
        )
      );
    }
    # Create (and configure) a local database if desired
    (mkIf (cfg.enable && cfg.enableLocalDB) {
      services.postgresql = {
        enable = true;
        ensureUsers = [
          {
            name = "firezone";
            ensureDBOwnership = true;
            # Required to create the publication and replication slot which
            # firezone uses to propagate changes to connected clients
            ensureClauses.superuser = true;
          }
        ];
        ensureDatabases = [ "firezone" ];
        # Firezone uses an internal replication strategy
        # that depends on a logical wal
        settings.wal_level = "logical";
      };

      services.firezone.server.settings = {
        DATABASE_SOCKET_DIR = "/run/postgresql";
        DATABASE_PORT = "5432";
        DATABASE_NAME = "firezone";
        DATABASE_USER = "firezone";
        DATABASE_PASSWORD = "firezone";
      };
    })
    # Create a local nginx reverse proxy
    (mkIf (cfg.enable && cfg.nginx.enable) {
      services.firezone.server.portal.trustedProxies = mkDefault [
        "127.0.0.1"
        "::1"
      ];

      services.nginx = {
        enable = true;
        # The portal dispatches requests based on the Host header
        recommendedProxySettings = mkDefault true;
        virtualHosts =
          let
            mkVirtualHost = url: {
              forceSSL = mkDefault true;
              locations.${url.location} = {
                # The trailing slash is important to strip the location prefix from the request
                proxyPass = "http://${listenHost}:${toString cfg.portal.port}/";
                proxyWebsockets = true;
              };
            };
          in
          {
            ${webUrl.domain} = mkVirtualHost webUrl;
            ${apiUrl.domain} = mkVirtualHost apiUrl;
          };
      };
    })
    # Specify sensible defaults
    (mkIf cfg.enable {
      services.firezone.server.settings = {
        LOG_LEVEL = mkDefault "info";
        RELEASE_HOSTNAME = mkDefault "localhost.localdomain";
        ERLANG_DISTRIBUTION_PORT = mkDefault 9000;

        ERLANG_CLUSTER_ADAPTER = mkDefault "Elixir.Cluster.Strategy.Epmd";
        ERLANG_CLUSTER_ADAPTER_CONFIG = mkDefault (
          builtins.toJSON {
            hosts = cfg.clusterHosts;
          }
        );

        # By default this will open nproc * 2 connections, which can exceed the
        # (default) maximum of 100 connections for postgresql on a 12 core +SMT
        # machine. 16 connections will be sufficient for small to medium deployments
        DATABASE_POOL_SIZE = mkDefault 16;

        # Changes to policies, resources, etc. are propagated to connected
        # clients and gateways via logical replication. Upstream disables this
        # by default because their deployment runs dedicated replication nodes.
        CHANGES_REPLICATION_ENABLED = mkDefault true;

        WEB_EXTERNAL_URL = mkDefault cfg.web.externalUrl;
        API_EXTERNAL_URL = mkDefault cfg.api.externalUrl;

        PHOENIX_LISTEN_ADDRESS = mkDefault cfg.portal.address;
        PHOENIX_HTTP_PUBLIC_PORT = mkDefault cfg.portal.port;
        PHOENIX_EXTERNAL_TRUSTED_PROXIES = mkDefault (builtins.toJSON cfg.portal.trustedProxies);
        PHOENIX_SECURE_COOKIES = mkDefault true; # enforce HTTPS on cookies

        # The internal ops endpoint is protected by HTTP basic auth, the
        # password is generated automatically unless provided via settingsSecret.
        PHOENIX_HTTP_OPS_PORT = mkDefault 13002;
        OPS_ADMIN_USERNAME = mkDefault "admin";
      };
    })
    (mkIf (cfg.enable && !cfg.smtp.configureManually) {
      services.firezone.server.settings = {
        OUTBOUND_EMAIL_ADAPTER = "Elixir.Swoosh.Adapters.Mua";
        OUTBOUND_EMAIL_ADAPTER_OPTS = builtins.toJSON { };
        OUTBOUND_EMAIL_FROM = cfg.smtp.from;
        OUTBOUND_EMAIL_SMTP_HOST = cfg.smtp.host;
        OUTBOUND_EMAIL_SMTP_PORT = toString cfg.smtp.port;
        OUTBOUND_EMAIL_SMTP_PROTOCOL = if cfg.smtp.implicitTls then "ssl" else "tcp";
        OUTBOUND_EMAIL_SMTP_USERNAME = cfg.smtp.username;
      };
      services.firezone.server.settingsSecret = {
        OUTBOUND_EMAIL_SMTP_PASSWORD = cfg.smtp.passwordFile;
      };
    })
    (mkIf (cfg.enable && cfg.openClusterFirewall) {
      networking.firewall.allowedTCPPorts = [
        (toInt (toString cfg.settings.ERLANG_DISTRIBUTION_PORT))
      ];
    })
    (mkIf cfg.enable {
      systemd.services.firezone-server = {
        description = "Backend portal server for the Firezone zero-trust access platform";
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ] ++ optional cfg.enableLocalDB "postgresql.target";
        requires = mkIf cfg.enableLocalDB [ "postgresql.target" ];

        preStart = ''
          # Generate and load secrets
          ${generateSecrets}
          ${loadSecretEnvironment}

          echo "Running migrations"
          ${getExe cfg.package} eval 'Portal.Release.migrate(manual: true)'
        '';

        script = ''
          ${loadSecretEnvironment}
          exec ${getExe cfg.package} start
        '';

        path = [ pkgs.curl ];
        postStart = ''
          # Wait for the firezone server to become ready
          count=0
          until curl -sf "http://${localHost}:${toString cfg.portal.port}/readyz" | grep -q '"status":"ready"'; do
            sleep 1
            count=$((count + 1))
            if [[ "$count" -ge 120 ]]; then
              echo "The portal did not become ready within 120 seconds, giving up..."
              exit 1
            fi
          done
        ''
        + optionalString cfg.provision.enable ''
          ${loadSecretEnvironment}
          ${secretsReplacement.script}
          ${getExe cfg.package} rpc 'Code.eval_file("${./provision.exs}")'
        '';

        environment = portalEnvironment;
        serviceConfig = commonServiceConfig // {
          LoadCredential = secretsReplacement.credentials ++ commonServiceConfig.LoadCredential;
        };
      };
    })
  ];

  meta.maintainers = with lib.maintainers; [
    oddlama
    patrickdag
  ];
}
