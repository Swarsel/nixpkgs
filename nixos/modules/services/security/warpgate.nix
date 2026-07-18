{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.warpgate;
  yaml = pkgs.formats.yaml { };
in
{
  options.services.warpgate =
    let
      inherit (lib.types)
        nullOr
        enum
        str
        bool
        port
        listOf
        attrsOf
        submodule
        ;
      inherit (lib.options) mkOption mkPackageOption literalExpression;
    in
    {
      enable = mkOption {
        default = false;

        description = ''
          Whether to enable Warpgate.
          This module will initialize Warpgate base on your config automatically. Please run `warpgate recover-access` to gain access.
        '';

        type = bool;
      };

      package = mkPackageOption pkgs "warpgate" { };

      databaseUrlFile = mkOption {
        default = null;

        description = ''
          Path to file containing database connection string with credentials.
          Should be a one line file with: `database_url: <protocol>://<username>:<password>@<host>/<database>`.
          See [SeaORM documentation](https://www.sea-ql.org/SeaORM/docs/install-and-config/connection/).
        '';

        type = nullOr str;
      };

      settings = mkOption {
        default = { };
        description = "Warpgate configuration.";

        example = {
          http = {
            listen = "[::]:8011";
          };

          ssh = {
            enable = true;
            listen = "[::]:2211";
          };
        };

        type = submodule {
          options = {
            database_url = mkOption {
              default = "sqlite:/var/lib/warpgate/db";

              description = ''
                Database connection string.
                See [SeaORM documentation](https://www.sea-ql.org/SeaORM/docs/install-and-config/connection/).
              '';

              type = nullOr str;
            };

            external_host = mkOption {
              default = null;

              description = ''
                Configure the domain name of this Warpgate instance.
                See [HTTP domain binding](https://warpgate.null.page/http-domain-binding/).
                This option is considered legacy, please use protocol specific `external_host` instead.
              '';

              type = nullOr str;
            };

            http = {
              certificate = mkOption {
                default = "/var/lib/warpgate/tls.certificate.pem";
                description = "Path to HTTPS listener certificate.";
                type = str;
              };

              cookie_max_age = mkOption {
                default = "1day";
                description = "How long until logged in cookie expires.";
                type = str;
              };

              external_host = mkOption {
                default = null;
                description = "The HTTP listener is reachable via this domain name externally.";
                type = nullOr str;
              };

              external_port = mkOption {
                default = null;
                description = "The HTTP listener is reachable via this port externally.";
                type = nullOr port;
              };

              key = mkOption {
                default = "/var/lib/warpgate/tls.key.pem";
                description = "Path to HTTPS listener private key.";
                type = str;
              };

              listen = mkOption {
                default = "[::]:8888";
                description = "Listen endpoint of HTTP listener.";
                type = str;
              };

              session_max_age = mkOption {
                default = "30m";
                description = "How long until a logged in session expires.";
                type = str;
              };

              sni_certificates = mkOption {
                default = [ ];
                description = "Certificates for additional domains.";

                example = literalExpression ''
                  [
                    {
                      certificate = "/var/lib/warpgate/example.tld.pem";
                      key = "/var/lib/warpgate/example.tld.key.pem";
                    }
                    {
                      ...
                    }
                  ]
                '';

                type = listOf (submodule {
                  options = {
                    certificate = mkOption {
                      default = "";
                      description = "Path to certificate.";
                      type = str;
                    };

                    key = mkOption {
                      default = "";
                      description = "Path to private key.";
                      type = str;
                    };
                  };

                  freeformType = yaml.type;
                });
              };

              trust_x_forwarded_headers = mkOption {
                default = false;

                description = ''
                  Trust X-Forwarded-* headers. Required when being reverse proxied.
                  See [Running behind a reverse proxy](https://warpgate.null.page/reverse-proxy/).
                '';

                type = bool;
              };
            };

            kubernetes = {
              enable = mkOption {
                default = false;
                description = "Whether to enable Kubernetes listener.";
                type = bool;
              };

              certificate = mkOption {
                default = "/var/lib/warpgate/tls.certificate.pem";
                description = "Path to Kubernetes listener certificate.";
                type = str;
              };

              external_host = mkOption {
                default = null;
                description = "The Kubernetes listener is reachable via this domain name externally.";
                type = nullOr str;
              };

              external_port = mkOption {
                default = null;
                description = "The Kubernetes listener is reachable via this port externally.";
                type = nullOr str;
              };

              key = mkOption {
                default = "/var/lib/warpgate/tls.key.pem";
                description = "Path to Kubernetes listener private key.";
                type = str;
              };

              listen = mkOption {
                default = "[::]:8443";
                description = "Listen endpoint of Kubernetes listener.";
                type = str;
              };

              session_max_age = mkOption {
                default = "30m";
                description = "How long until a logged in session expires.";
                type = str;
              };
            };

            log = {
              audit_retention = mkOption {
                default = "1year";
                description = "How long Warpgate keeps its audit logs.";
                type = str;
              };

              format = mkOption {
                default = "text";
                description = "The format Warpgate emits logs in.";

                type = enum [
                  "text"
                  "json"
                ];
              };

              retention = mkOption {
                default = "7days";
                description = "How long Warpgate keeps its non-audit logs and session recordings.";
                type = str;
              };

              send_to = mkOption {
                default = null;

                description = ''
                  Path of UNIX socket of log forwarder.
                  See [Log forwarding](https://warpgate.null.page/log-forwarding/);
                '';

                type = nullOr str;
              };
            };

            mysql = {
              enable = mkOption {
                default = false;
                description = "Whether to enable MySQL listener.";
                type = bool;
              };

              certificate = mkOption {
                default = "/var/lib/warpgate/tls.certificate.pem";
                description = "Path to MySQL listener certificate.";
                type = str;
              };

              external_host = mkOption {
                default = null;
                description = "The MySQL listener is reachable via this domain name externally.";
                type = nullOr str;
              };

              external_port = mkOption {
                default = null;
                description = "The MySQL listener is reachable via this port externally.";
                type = nullOr port;
              };

              key = mkOption {
                default = "/var/lib/warpgate/tls.key.pem";
                description = "Path to MySQL listener private key.";
                type = str;
              };

              listen = mkOption {
                default = "[::]:33306";
                description = "Listen endpoint of MySQL listener.";
                type = str;
              };
            };

            postgres = {
              enable = mkOption {
                default = false;
                description = "Whether to enable PostgreSQL listener.";
                type = bool;
              };

              certificate = mkOption {
                default = "/var/lib/warpgate/tls.certificate.pem";
                description = "Path to PostgreSQL listener certificate.";
                type = str;
              };

              external_host = mkOption {
                default = null;
                description = "The PostgreSQL listener is reachable via this domain name externally.";
                type = nullOr str;
              };

              external_port = mkOption {
                default = null;
                description = "The PostgreSQL listener is reachable via this port externally.";
                type = nullOr str;
              };

              key = mkOption {
                default = "/var/lib/warpgate/tls.key.pem";
                description = "Path to PostgreSQL listener private key.";
                type = str;
              };

              listen = mkOption {
                default = "[::]:55432";
                description = "Listen endpoint of PostgreSQL listener.";
                type = str;
              };
            };

            recordings = {
              enable = mkOption {
                default = true;
                description = "Whether to enable session recording.";
                type = bool;
              };

              path = mkOption {
                default = "/var/lib/warpgate/recordings";
                description = "Path to store session recordings.";
                type = str;
              };
            };

            ssh = {
              enable = mkOption {
                default = false;
                description = "Whether to enable SSH listener.";
                type = bool;
              };

              external_host = mkOption {
                default = null;
                description = "The SSH listener is reachable via this domain name externally.";
                type = nullOr str;
              };

              external_port = mkOption {
                default = null;
                description = "The SSH listener is reachable via this port externally.";
                type = nullOr port;
              };

              host_key_verification = mkOption {
                default = "prompt";
                description = "Specify host key verification action when connecting to a SSH target with unknown/differing host key.";

                type = enum [
                  "prompt"
                  "auto_accept"
                  "auto_reject"
                ];
              };

              inactivity_timeout = mkOption {
                default = "5m";
                description = "How long can user be inactive until Warpgate terminates the connection.";
                type = str;
              };

              keepalive_interval = mkOption {
                default = null;
                description = "If nothing is received from the client for this amount of time, server will send a keepalive message.";
                type = nullOr str;
              };

              keys = mkOption {
                default = "/var/lib/warpgate/ssh-keys";
                description = "Path to store SSH host & client keys.";
                type = str;
              };

              listen = mkOption {
                default = "[::]:2222";
                description = "Listen endpoint of SSH listener.";
                type = str;
              };
            };

            sso_providers = mkOption {
              default = [ ];

              description = ''
                Configure OIDC single sign-on providers.
                Main documentation can be found [here](https://warpgate.null.page/sso).
              '';

              example = literalExpression ''
                [
                  {
                    name = "3rd party SSO";
                    label = "ACME SSO";
                    provider = {
                      type = "custom";
                      client_id = "123...";
                      client_secret = "BC...";
                      issuer_url = "https://sso.acme.inc";
                      scopes = ["email"];
                    };
                  }
                  {
                    ...
                  }
                ]
              '';

              type = listOf (submodule {
                options = {
                  auto_create_users = mkOption {
                    default = false;
                    description = "Whether to create user automatically at first SSO login.";
                    type = bool;
                  };

                  label = mkOption {
                    default = null;
                    description = "SSO provider name displayed on login page.";
                    type = nullOr str;
                  };

                  name = mkOption {
                    description = "Internal identifier of SSO provider.";
                    type = str;
                  };

                  provider = mkOption {
                    description = ''
                      SSO provider configurations.
                      See [here](https://github.com/warp-tech/warpgate/blob/ffc755f0137944bd39cf4cbce90f4279da500943/config-schema.json#L430) for all acceptable options.
                    '';

                    type = attrsOf yaml.type;
                  };

                  return_domain_whitelist = mkOption {
                    default = null;

                    description = ''
                      Controls the SSO return URL supplied to SSO provider.
                      This will also required you to connect to this instance via whitelisted domain when doing SSO login.
                    '';

                    type = nullOr (listOf str);
                  };

                  return_url_prefix = mkOption {
                    default = "@";

                    description = ''
                      Controls the SSO return URL supplied to SSO provider.
                      Useful for providers that do not allow the @ sign in the URL (e.g. Azure).
                    '';

                    type = enum [
                      "@"
                      "_"
                    ];
                  };
                };

                freeformType = yaml.type;
              });
            };
          };

          freeformType = yaml.type;
        };
      };
    };

  config =
    let
      inherit (lib.lists)
        any
        map
        head
        reverseList
        ;
      inherit (lib.strings) splitString toIntBase10;

      preStartScript = pkgs.writers.writeBash "warpgate-init" ''
        CFGFILE=/var/lib/warpgate/config.yaml
        if [ ! -O $CFGFILE ] || [ ! -s $CFGFILE ]; then
          INITPWD=$(tr -dc 'A-Za-z0-9!?%=' </dev/urandom 2>/dev/null | head -c 16)
          ${lib.getExe cfg.package} \
            --config $CFGFILE unattended-setup \
            --data-path /var/lib/warpgate \
            --http-port 8888 \
            --admin-password $INITPWD
        fi
        ${
          if cfg.databaseUrlFile != null then
            ''
              sed -e '/^database_url: null/d' ${yaml.generate "warpgate-config" cfg.settings} > $CFGFILE
              cat /run/credentials/warpgate.service/databaseUrl >> $CFGFILE
            ''
          else
            "cp --no-preserve=ownership ${yaml.generate "warpgate-config" cfg.settings} $CFGFILE"
        }
      '';
      bindOnPrivilegedPorts = any (x: toIntBase10 x < 1025) (
        map (x: head (reverseList (splitString ":" x))) (
          [ cfg.settings.http.listen ]
          ++ lib.optional cfg.settings.ssh.enable cfg.settings.ssh.listen
          ++ lib.optional cfg.settings.mysql.enable cfg.settings.mysql.listen
          ++ lib.optional cfg.settings.postgres.enable cfg.settings.postgres.listen
        )
      );
    in
    lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = !((cfg.databaseUrlFile != null) && (cfg.settings.database_url != null));
          message = "You cannot configure databaseUrlFile and settings.database_url at the same time.";
        }
        {
          assertion = !((cfg.databaseUrlFile == null) && (cfg.settings.database_url == null));
          message = "Either databaseUrlFile or settings.database_url must be set; Set the other to null.";
        }
        {
          assertion = !(lib.hasAttr "config_provider" cfg.settings);
          message = "`services.warpgate.settings.config_provider` is a legacy option that has been removed since 0.14.0. Please do not set this option.";
        }
      ];

      environment.systemPackages = [ cfg.package ];

      systemd.services.warpgate = {
        after = [ "network.target" ];
        description = "Warpgate smart bastion";

        serviceConfig = {
          DeviceAllow = [
            "/dev/null rw"
            "/dev/urandom r"
          ];

          DevicePolicy = "strict";
          DynamicUser = true;
          ExecStart = "${lib.getExe cfg.package} --config /var/lib/warpgate/config.yaml run";
          ExecStartPre = preStartScript;

          LoadCredential = "${
            if cfg.databaseUrlFile != null then "databaseUrl:${cfg.databaseUrlFile}" else ""
          }";

          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "full";
          RemoveIPC = true;
          Restart = "on-failure";
          RestartSec = 3;

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          StateDirectory = "warpgate";
          StateDirectoryMode = "0700";
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
          ];
        }
        // (
          if bindOnPrivilegedPorts then
            {
              AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
              CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
            }
          else
            {
              PrivateUsers = true;
            }
        );

        startLimitBurst = 5;
        wantedBy = [ "multi-user.target" ];
      };
    };

  meta.maintainers = with lib.maintainers; [ alemonmk ];
}
