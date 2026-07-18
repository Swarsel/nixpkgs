{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.misskey;
  settingsFormat = pkgs.formats.yaml { };
  redisType = lib.types.submodule {
    options = {
      host = lib.mkOption {
        default = "localhost";
        description = "The Redis host.";
        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 6379;
        description = "The Redis port.";
        type = lib.types.port;
      };
    };

    freeformType = lib.types.attrsOf settingsFormat.type;
  };
  settings = lib.mkOption {
    description = ''
      Configuration for Misskey, see
      [`example.yml`](https://github.com/misskey-dev/misskey/blob/develop/.config/example.yml)
      for all supported options.
    '';

    type = lib.types.submodule {
      options = {
        chmodSocket = lib.mkOption {
          default = null;
          description = "The file access mode of the UNIX socket.";
          example = "777";
          type = lib.types.nullOr lib.types.str;
        };

        db = lib.mkOption {
          default = { };
          description = "Database settings.";

          type = lib.types.submodule {
            options = {
              db = lib.mkOption {
                default = "misskey";
                description = "The database name.";
                type = lib.types.str;
              };

              disableCache = lib.mkOption {
                default = false;
                description = "Whether to disable caching queries.";
                type = lib.types.bool;
              };

              extra = lib.mkOption {
                default = null;
                description = "Extra connection options.";

                example = {
                  ssl = true;
                };

                type = lib.types.nullOr (lib.types.attrsOf settingsFormat.type);
              };

              host = lib.mkOption {
                default = "/var/run/postgresql";
                description = "The PostgreSQL host.";
                example = "localhost";
                type = lib.types.str;
              };

              pass = lib.mkOption {
                default = null;
                description = "The password used for database authentication.";
                type = lib.types.nullOr lib.types.str;
              };

              port = lib.mkOption {
                default = 5432;
                description = "The PostgreSQL port.";
                type = lib.types.port;
              };

              user = lib.mkOption {
                default = "misskey";
                description = "The user used for database authentication.";
                type = lib.types.str;
              };
            };
          };
        };

        id = lib.mkOption {
          default = "aidx";
          description = "The ID generation method to use. Do not change after starting Misskey for the first time.";

          type = lib.types.enum [
            "aid"
            "aidx"
            "meid"
            "ulid"
            "objectid"
          ];
        };

        meilisearch = lib.mkOption {
          default = null;
          description = "Meilisearch connection options.";

          type = lib.types.nullOr (
            lib.types.submodule {
              options = {
                apiKey = lib.mkOption {
                  default = null;
                  description = "The Meilisearch API key.";
                  type = lib.types.nullOr lib.types.str;
                };

                host = lib.mkOption {
                  default = "localhost";
                  description = "The Meilisearch host.";
                  type = lib.types.str;
                };

                index = lib.mkOption {
                  default = null;
                  description = "Meilisearch index to use.";
                  type = lib.types.nullOr lib.types.str;
                };

                port = lib.mkOption {
                  default = 7700;
                  description = "The Meilisearch port.";
                  type = lib.types.port;
                };

                scope = lib.mkOption {
                  default = "local";
                  description = "The search scope.";

                  type = lib.types.enum [
                    "local"
                    "global"
                  ];
                };

                ssl = lib.mkOption {
                  default = false;
                  description = "Whether to connect via SSL.";
                  type = lib.types.bool;
                };
              };
            }
          );
        };

        port = lib.mkOption {
          default = 3000;
          description = "The port your Misskey server should listen on.";
          type = lib.types.port;
        };

        redis = lib.mkOption {
          default = { };
          description = "`ioredis` options. See [`README`](https://github.com/redis/ioredis?tab=readme-ov-file#connect-to-redis) for reference.";
          type = redisType;
        };

        redisForJobQueue = lib.mkOption {
          default = null;
          description = "`ioredis` options for the job queue. See [`README`](https://github.com/redis/ioredis?tab=readme-ov-file#connect-to-redis) for reference.";
          type = lib.types.nullOr redisType;
        };

        redisForPubsub = lib.mkOption {
          default = null;
          description = "`ioredis` options for pubsub. See [`README`](https://github.com/redis/ioredis?tab=readme-ov-file#connect-to-redis) for reference.";
          type = lib.types.nullOr redisType;
        };

        redisForTimelines = lib.mkOption {
          default = null;
          description = "`ioredis` options for timelines. See [`README`](https://github.com/redis/ioredis?tab=readme-ov-file#connect-to-redis) for reference.";
          type = lib.types.nullOr redisType;
        };

        socket = lib.mkOption {
          default = null;
          description = "The UNIX socket your Misskey server should listen on.";
          example = "/path/to/misskey.sock";
          type = lib.types.nullOr lib.types.path;
        };

        url = lib.mkOption {
          description = ''
            The final user-facing URL. Do not change after running Misskey for the first time.

            This needs to match up with the configured reverse proxy and is automatically configured when using `services.misskey.reverseProxy`.
          '';

          example = "https://example.tld/";
          type = lib.types.str;
        };
      };

      freeformType = lib.types.attrsOf settingsFormat.type;
    };
  };
in

{
  options = {
    services.misskey = {
      inherit settings;
      enable = lib.mkEnableOption "misskey";
      package = lib.mkPackageOption pkgs "misskey" { };

      database = {
        createLocally = lib.mkOption {
          default = false;
          description = "Create the PostgreSQL database locally. Sets `services.misskey.settings.db.{db,host,port,user,pass}`.";
          type = lib.types.bool;
        };

        passwordFile = lib.mkOption {
          default = null;
          description = "The path to a file containing the database password. Sets `services.misskey.settings.db.pass`.";
          type = lib.types.nullOr lib.types.path;
        };
      };

      meilisearch = {
        createLocally = lib.mkOption {
          default = false;
          description = "Create and use a local Meilisearch instance. Sets `services.misskey.settings.meilisearch.{host,port,ssl}`.";
          type = lib.types.bool;
        };

        keyFile = lib.mkOption {
          default = null;
          description = "The path to a file containing the Meilisearch API key. Sets `services.misskey.settings.meilisearch.apiKey`.";
          type = lib.types.nullOr lib.types.path;
        };
      };

      redis = {
        createLocally = lib.mkOption {
          default = false;
          description = "Create and use a local Redis instance. Sets `services.misskey.settings.redis.host`.";
          type = lib.types.bool;
        };

        passwordFile = lib.mkOption {
          default = null;
          description = "The path to a file containing the Redis password. Sets `services.misskey.settings.redis.pass`.";
          type = lib.types.nullOr lib.types.path;
        };
      };

      reverseProxy = {
        enable = lib.mkEnableOption "a HTTP reverse proxy for Misskey";

        host = lib.mkOption {
          default = null;

          description = ''
            The fully qualified domain name to bind to. Sets `services.misskey.settings.url`.

            This is required when using `services.misskey.reverseProxy.enable = true`.
          '';

          example = "misskey.example.com";
          type = lib.types.nullOr lib.types.str;
        };

        ssl = lib.mkOption {
          default = null;

          description = ''
            Whether to enable SSL for the reverse proxy. Sets `services.misskey.settings.url`.

            This is required when using `services.misskey.reverseProxy.enable = true`.
          '';

          example = true;
          type = lib.types.nullOr lib.types.bool;
        };

        webserver = lib.mkOption {
          description = "The webserver to use as the reverse proxy.";

          type = lib.types.attrTag {
            caddy = lib.mkOption {
              default = { };

              description = ''
                Extra configuration for the caddy virtual host of Misskey.
                Set to `{ }` to use the default configuration.
              '';

              type = lib.types.submodule (
                import ../web-servers/caddy/vhost-options.nix { cfg = config.services.caddy; }
              );
            };

            nginx = lib.mkOption {
              default = { };

              description = ''
                Extra configuration for the nginx virtual host of Misskey.
                Set to `{ }` to use the default configuration.
              '';

              type = lib.types.submodule (import ../web-servers/nginx/vhost-options.nix);
            };
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          cfg.reverseProxy.enable -> ((cfg.reverseProxy.host != null) && (cfg.reverseProxy.ssl != null));

        message = "`services.misskey.reverseProxy.enable` requires `services.misskey.reverseProxy.host` and `services.misskey.reverseProxy.ssl` to be set.";
      }
    ];

    services.caddy = lib.mkIf (cfg.reverseProxy.enable && cfg.reverseProxy.webserver ? caddy) {
      enable = true;

      virtualHosts.${cfg.settings.url} = lib.mkMerge [
        cfg.reverseProxy.webserver.caddy
        {
          extraConfig = ''
            reverse_proxy localhost:${toString cfg.settings.port}
          '';

          hostName = lib.mkDefault cfg.settings.url;
        }
      ];
    };

    services.meilisearch = lib.mkIf cfg.meilisearch.createLocally { enable = true; };

    services.misskey.settings = lib.mkMerge [
      (lib.mkIf cfg.database.createLocally {
        db = {
          db = lib.mkDefault "misskey";
          # Use unix socket instead of localhost to allow PostgreSQL peer authentication,
          # required for `services.postgresql.ensureUsers`
          host = lib.mkDefault "/var/run/postgresql";
          pass = lib.mkDefault null;
          port = lib.mkDefault config.services.postgresql.settings.port;
          user = lib.mkDefault "misskey";
        };
      })
      (lib.mkIf (cfg.database.passwordFile != null) { db.pass = lib.mkDefault "@DATABASE_PASSWORD@"; })
      (lib.mkIf cfg.redis.createLocally { redis.host = lib.mkDefault "localhost"; })
      (lib.mkIf (cfg.redis.passwordFile != null) { redis.pass = lib.mkDefault "@REDIS_PASSWORD@"; })
      (lib.mkIf cfg.meilisearch.createLocally {
        meilisearch = {
          host = lib.mkDefault "localhost";
          port = lib.mkDefault config.services.meilisearch.listenPort;
          ssl = lib.mkDefault false;
        };
      })
      (lib.mkIf (cfg.meilisearch.keyFile != null) {
        meilisearch.apiKey = lib.mkDefault "@MEILISEARCH_KEY@";
      })
      (lib.mkIf cfg.reverseProxy.enable {
        url = lib.mkDefault "${
          if cfg.reverseProxy.ssl then "https" else "http"
        }://${cfg.reverseProxy.host}";
      })
    ];

    services.nginx = lib.mkIf (cfg.reverseProxy.enable && cfg.reverseProxy.webserver ? nginx) {
      enable = true;

      virtualHosts.${cfg.reverseProxy.host} = lib.mkMerge [
        cfg.reverseProxy.webserver.nginx
        {
          locations."/" = {
            proxyPass = lib.mkDefault "http://localhost:${toString cfg.settings.port}";
            proxyWebsockets = lib.mkDefault true;
            recommendedProxySettings = lib.mkDefault true;
          };
        }
        (lib.mkIf (cfg.reverseProxy.ssl != null) { forceSSL = lib.mkDefault cfg.reverseProxy.ssl; })
      ];
    };

    services.postgresql = lib.mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ "misskey" ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = "misskey";
        }
      ];
    };

    services.redis.servers = lib.mkIf cfg.redis.createLocally {
      misskey = {
        enable = true;
        port = cfg.settings.redis.port;
      };
    };

    systemd.services.misskey = {
      after = [
        "network-online.target"
        "postgresql.target"
      ];

      environment = {
        MISSKEY_CONFIG_YML = "/run/misskey/default.yml";
      };

      preStart = ''
        install -m 700 ${settingsFormat.generate "misskey-config.yml" cfg.settings} /run/misskey/default.yml
        install -m 700 ${
          (pkgs.formats.json { }).generate "misskey-config.json" cfg.settings
        } /run/misskey/default.json
      ''
      + (lib.optionalString (cfg.database.passwordFile != null) ''
        ${pkgs.replace-secret}/bin/replace-secret '@DATABASE_PASSWORD@' "${cfg.database.passwordFile}" /run/misskey/default.yml
      '')
      + (lib.optionalString (cfg.redis.passwordFile != null) ''
        ${pkgs.replace-secret}/bin/replace-secret '@REDIS_PASSWORD@' "${cfg.redis.passwordFile}" /run/misskey/default.yml
      '')
      + (lib.optionalString (cfg.meilisearch.keyFile != null) ''
        ${pkgs.replace-secret}/bin/replace-secret '@MEILISEARCH_KEY@' "${cfg.meilisearch.keyFile}" /run/misskey/default.yml
      '');

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/misskey migrateandstart";
        LockPersonality = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX AF_NETLINK";
        RuntimeDirectory = "misskey";
        RuntimeDirectoryMode = "700";
        StateDirectory = "misskey";
        StateDirectoryMode = "700";
        TimeoutSec = 60;
        User = "misskey";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta = {
    maintainers = [ lib.maintainers.feathecutie ];
  };
}
