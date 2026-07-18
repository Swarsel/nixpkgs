{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ncps;

  logLevels = [
    "trace"
    "debug"
    "info"
    "warn"
    "error"
    "fatal"
    "panic"
  ];

  ncpsWrapper = pkgs.writeShellScript "ncps-wrapper" ''
    ${lib.optionalString (cfg.cache.secretKeyPath != null) ''
      export CACHE_SECRET_KEY_PATH="$CREDENTIALS_DIRECTORY/secretKey"
    ''}

    ${lib.optionalString (cfg.cache.storage.s3 != null) ''
      export CACHE_STORAGE_S3_ACCESS_KEY_ID="$(cat "$CREDENTIALS_DIRECTORY/s3AccessKeyId")"
      export CACHE_STORAGE_S3_SECRET_ACCESS_KEY="$(cat "$CREDENTIALS_DIRECTORY/s3SecretAccessKey")"
    ''}

    ${lib.optionalString (cfg.cache.redis != null) (
      if cfg.cache.redis.passwordFile != null then
        ''export CACHE_REDIS_PASSWORD="$(cat "$CREDENTIALS_DIRECTORY/redisPassword")"''
      else if cfg.cache.redis.password != null then
        ''export CACHE_REDIS_PASSWORD="${cfg.cache.redis.password}"''
      else
        ""
    )}

    ${lib.optionalString (cfg.cache.databaseURLFile != null) ''
      export CACHE_DATABASE_URL="$(cat "$CREDENTIALS_DIRECTORY/databaseURL")"
    ''}

    exec ${lib.getExe cfg.package} --config "${configFile}" "$@"
  '';

  settings = {
    analytics.reporting = {
      enabled = cfg.analytics.reporting.enable;
      samples = cfg.analytics.reporting.samples;
    };

    cache = {
      allow-delete-verb = cfg.cache.allowDeleteVerb;
      allow-put-verb = cfg.cache.allowPutVerb;

      cdc = {
        inherit (cfg.cache.cdc)
          enabled
          min
          avg
          max
          ;
      };

      database.pool = {
        max-idle-conns = cfg.cache.database.pool.maxIdleConns;
        max-open-conns = cfg.cache.database.pool.maxOpenConns;
      };

      database-url = cfg.cache.databaseURL;
      hostname = cfg.cache.hostName;

      lock = {
        allow-degraded-mode = cfg.cache.lock.allowDegradedMode;
        backend = cfg.cache.lock.backend;
        download-lock-ttl = cfg.cache.lock.downloadTTL;
        lru-lock-ttl = cfg.cache.lock.lruTTL;
        redis.key-prefix = cfg.cache.lock.redisKeyPrefix;

        retry = {
          initial-delay = cfg.cache.lock.retry.initialDelay;
          jitter = cfg.cache.lock.retry.jitter;
          max-attempts = cfg.cache.lock.retry.maxAttempts;
          max-delay = cfg.cache.lock.retry.maxDelay;
        };
      };

      lru = {
        schedule = cfg.cache.lru.schedule;
        timezone = cfg.cache.lru.scheduleTimeZone;
      };

      max-size = cfg.cache.maxSize;
      netrc-file = cfg.netrcFile;

      redis = lib.optionalAttrs (cfg.cache.redis != null) {
        addrs = cfg.cache.redis.addresses;
        db = cfg.cache.redis.database;
        pool-size = cfg.cache.redis.poolSize;
        use-tls = cfg.cache.redis.useTLS;
        username = cfg.cache.redis.username;
      };

      sign-narinfo = cfg.cache.signNarinfo;

      storage =
        if cfg.cache.storage.s3 != null then
          {
            s3 = {
              bucket = cfg.cache.storage.s3.bucket;
              endpoint = cfg.cache.storage.s3.endpoint;
              force-path-style = cfg.cache.storage.s3.forcePathStyle;
              region = cfg.cache.storage.s3.region;
            };
          }
        else
          {
            local = cfg.cache.storage.local;
          };

      temp-path = cfg.cache.tempPath;

      upstream = {
        dialer-timeout = cfg.cache.upstream.dialerTimeout;
        public-keys = cfg.cache.upstream.publicKeys;
        response-header-timeout = cfg.cache.upstream.responseHeaderTimeout;
        urls = cfg.cache.upstream.urls;
      };
    };

    log.level = cfg.logLevel;

    opentelemetry = lib.optionalAttrs cfg.openTelemetry.enable {
      enabled = true;
      grpc-url = cfg.openTelemetry.grpcURL;
    };

    prometheus = lib.optionalAttrs cfg.prometheus.enable {
      enabled = true;
    };

    server.addr = cfg.server.addr;
  };

  configFile = pkgs.writeText "ncps-config.json" (
    builtins.toJSON (
      lib.filterAttrsRecursive (_: v: v != null && v != { } && v != "" && v != [ ]) settings
    )
  );

  isSqlite = cfg.cache.databaseURL != null && lib.strings.hasPrefix "sqlite:" cfg.cache.databaseURL;

  dbPath = if isSqlite then lib.removePrefix "sqlite:" cfg.cache.databaseURL else null;
  dbDir = if isSqlite then dirOf dbPath else null;
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "ncps" "cache" "dataPath" ]
      [ "services" "ncps" "cache" "storage" "local" ]
    )

    (lib.mkRenamedOptionModule
      [ "services" "ncps" "upstream" "caches" ]
      [ "services" "ncps" "cache" "upstream" "urls" ]
    )

    (lib.mkRenamedOptionModule
      [ "services" "ncps" "upstream" "publicKeys" ]
      [ "services" "ncps" "cache" "upstream" "publicKeys" ]
    )

    (lib.mkRemovedOptionModule [
      "services"
      "ncps"
      "dbmatePackage"
    ] "dbmate is now wrapped within ncps package, you need to override ncps to change dbmate package")

    (lib.mkRemovedOptionModule [
      "services"
      "ncps"
      "cache"
      "lock"
      "postgresKeyPrefix"
    ] "PostgreSQL lock backend was removed upstream")
  ];

  options = {
    services.ncps = {
      enable = lib.mkEnableOption "ncps: Nix binary cache proxy service implemented in Go";
      package = lib.mkPackageOption pkgs "ncps" { };

      analytics.reporting = {
        enable = lib.mkOption {
          default = true;

          description = ''
            Enable reporting anonymous usage statistics (DB type, Lock type, Total Size) to the project maintainers.
          '';

          type = lib.types.bool;
        };

        samples = lib.mkEnableOption "Enable printing the analytics samples to stdout. This is useful for debugging and verification purposes only.";
      };

      cache = {
        allowDeleteVerb = lib.mkEnableOption ''
          Whether to allow the DELETE verb to delete narinfo and nar files from
          the cache.
        '';

        allowPutVerb = lib.mkEnableOption ''
          Whether to allow the PUT verb to push narinfo and nar files directly
          to the cache.
        '';

        cdc = {
          avg = lib.mkOption {
            default = 65536;

            description = ''
              The average chunk size for CDC in bytes.
            '';

            type = lib.types.ints.u32;
          };

          enabled = lib.mkEnableOption ''
            Whether to enable Content-Defined Chunking (CDC) for deduplication (experimental).
          '';

          max = lib.mkOption {
            default = 262144;

            description = ''
              The maximum chunk size for CDC in bytes.
            '';

            type = lib.types.ints.u32;
          };

          min = lib.mkOption {
            default = 16384;

            description = ''
              The minimum chunk size for CDC in bytes.
            '';

            type = lib.types.ints.u32;
          };
        };

        database = {
          pool = {
            maxIdleConns = lib.mkOption {
              default = 0;

              description = ''
                Maximum number of idle connections in the pool (0 = use
                database-specific defaults).
              '';

              type = lib.types.int;
            };

            maxOpenConns = lib.mkOption {
              default = 0;

              description = ''
                Maximum number of open connections to the database (0 = use
                database-specific defaults).
              '';

              type = lib.types.int;
            };
          };
        };

        databaseURL = lib.mkOption {
          default = "sqlite:${cfg.cache.storage.local}/db/db.sqlite";
          defaultText = "sqlite:/var/lib/ncps/db/db.sqlite";

          description = ''
            The URL of the database (currently only SQLite is supported)
          '';

          type = lib.types.nullOr lib.types.str;
        };

        databaseURLFile = lib.mkOption {
          default = null;

          description = ''
            File containing the URL of the database.
          '';

          type = lib.types.nullOr lib.types.path;
        };

        hostName = lib.mkOption {
          description = ''
            The hostname of the cache server. **This is used to generate the
            private key used for signing store paths (.narinfo)**
          '';

          type = lib.types.str;
        };

        lock = {
          allowDegradedMode = lib.mkOption {
            default = false;

            description = ''
              Allow falling back to local locks if Redis is unavailable (WARNING:
              breaks HA guarantees).
            '';

            type = lib.types.bool;
          };

          backend = lib.mkOption {
            default = "local";

            description = ''
              Lock backend to use: 'local' (single instance), 'redis'
              (distributed).
            '';

            type = lib.types.enum [
              "local"
              "redis"
            ];
          };

          downloadTTL = lib.mkOption {
            default = "5m0s";

            description = ''
              TTL for download locks (per-hash locks).
            '';

            type = lib.types.str;
          };

          lruTTL = lib.mkOption {
            default = "30m0s";

            description = ''
              TTL for LRU lock (global exclusive lock).
            '';

            type = lib.types.str;
          };

          redisKeyPrefix = lib.mkOption {
            default = "ncps:lock:";

            description = ''
              Prefix for all Redis lock keys (only used when Redis is
              configured).
            '';

            type = lib.types.str;
          };

          retry = {
            initialDelay = lib.mkOption {
              default = "100ms";

              description = ''
                Initial retry delay for distributed locks.
              '';

              type = lib.types.str;
            };

            jitter = lib.mkOption {
              default = true;

              description = ''
                Enable jitter in retry delays to prevent thundering herd.
              '';

              type = lib.types.bool;
            };

            maxAttempts = lib.mkOption {
              default = 3;

              description = ''
                Maximum number of retry attempts for distributed locks.
              '';

              type = lib.types.int;
            };

            maxDelay = lib.mkOption {
              default = "2s";

              description = ''
                Maximum retry delay for distributed locks (exponential backoff
                caps at this).
              '';

              type = lib.types.str;
            };
          };
        };

        lru = {
          schedule = lib.mkOption {
            default = null;

            description = ''
              The cron spec for cleaning the store to keep it under
              config.ncps.cache.maxSize. Refer to
              https://pkg.go.dev/github.com/robfig/cron/v3#hdr-Usage for
              documentation.
            '';

            example = "0 2 * * *";
            type = lib.types.nullOr lib.types.str;
          };

          scheduleTimeZone = lib.mkOption {
            default = "Local";

            description = ''
              The name of the timezone to use for the cron schedule. See
              <https://en.wikipedia.org/wiki/List_of_tz_database_time_zones>
              for a comprehensive list of possible values for this setting.
            '';

            example = "America/Los_Angeles";
            type = lib.types.str;
          };
        };

        maxSize = lib.mkOption {
          default = null;

          description = ''
            The maximum size of the store. It can be given with units such as
            5K, 10G etc. Supported units: B, K, M, G, T.
          '';

          example = "100G";
          type = lib.types.nullOr lib.types.str;
        };

        redis = lib.mkOption {
          default = null;

          description = ''
            Configure Redis.
          '';

          type = lib.types.nullOr (
            lib.types.submodule {
              options = {
                addresses = lib.mkOption {
                  description = ''
                    A list of host:port for the Redis servers that are part of a cluster.
                    To use a single Redis instance, just set this to its single address.
                  '';

                  example = ''
                    ["redis0:6379" "redis1:6379"]
                  '';

                  type = lib.types.listOf lib.types.str;
                };

                database = lib.mkOption {
                  default = 0;

                  description = ''
                    Redis database number (0-15)
                  '';

                  type = lib.types.int;
                };

                password = lib.mkOption {
                  default = null;

                  description = ''
                    Redis password for authentication (for Redis ACL).
                  '';

                  type = lib.types.nullOr lib.types.str;
                };

                passwordFile = lib.mkOption {
                  default = null;

                  description = ''
                    File containing the redis password for authentication (for Redis ACL).
                  '';

                  type = lib.types.nullOr lib.types.path;
                };

                poolSize = lib.mkOption {
                  default = 10;

                  description = ''
                    Redis connection pool size.
                  '';

                  type = lib.types.int;
                };

                useTLS = lib.mkOption {
                  default = false;

                  description = ''
                    Use TLS for Redis connection.
                  '';

                  type = lib.types.bool;
                };

                username = lib.mkOption {
                  default = null;

                  description = ''
                    Redis username for authentication (for Redis ACL).
                  '';

                  type = lib.types.nullOr lib.types.str;
                };
              };
            }
          );
        };

        secretKeyPath = lib.mkOption {
          default = null;

          description = ''
            The path to load the secretKey for signing narinfos. Leave this
            empty to automatically generate a private/public key.
          '';

          type = lib.types.nullOr lib.types.path;
        };

        signNarinfo = lib.mkOption {
          default = true;

          description = ''
            Whether to sign narInfo files or passthru as-is from upstream
          '';

          example = false;
          type = lib.types.bool;
        };

        storage = {
          local = lib.mkOption {
            default = "/var/lib/ncps";

            description = ''
              The local directory for storing configuration and cached store
              paths. This is ignored if services.ncps.cache.storage.s3 is not
              null.
            '';

            type = lib.types.path;
          };

          s3 = lib.mkOption {
            default = null;

            description = ''
              Use S3 for storage instead of local storage.
            '';

            type = lib.types.nullOr (
              lib.types.submodule {
                options = {
                  accessKeyIdPath = lib.mkOption {
                    description = ''
                      The path to a file containing only the access-key-id.
                    '';

                    type = lib.types.path;
                  };

                  bucket = lib.mkOption {
                    description = ''
                      The name of the S3 bucket.
                    '';

                    type = lib.types.str;
                  };

                  endpoint = lib.mkOption {
                    description = ''
                      S3-compatible endpoint URL with scheme.
                    '';

                    example = "https://s3.amazonaws.com";
                    type = lib.types.str;
                  };

                  forcePathStyle = lib.mkOption {
                    default = false;

                    description = ''
                      Force path-style S3 addressing (bucket/key vs key.bucket).
                    '';

                    type = lib.types.bool;
                  };

                  region = lib.mkOption {
                    default = null;

                    description = ''
                      The S3 region.
                    '';

                    type = lib.types.nullOr lib.types.str;
                  };

                  secretAccessKeyPath = lib.mkOption {
                    description = ''
                      The path to a file containing only the secret-access-key.
                    '';

                    type = lib.types.path;
                  };
                };
              }
            );
          };
        };

        tempPath = lib.mkOption {
          default = "/tmp";

          description = ''
            The path to the temporary directory that is used by the cache to download NAR files
          '';

          type = lib.types.path;
        };

        upstream = {
          dialerTimeout = lib.mkOption {
            default = null;

            description = ''
              Timeout for establishing TCP connections to upstream caches (e.g., 3s, 5s, 10s).
            '';

            type = lib.types.nullOr lib.types.str;
          };

          publicKeys = lib.mkOption {
            default = [ ];

            description = ''
              A list of public keys of upstream caches in the format
              `host[-[0-9]*]:public-key`. This flag is used to verify the
              signatures of store paths downloaded from upstream caches.
            '';

            example = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
            type = lib.types.listOf lib.types.str;
          };

          responseHeaderTimeout = lib.mkOption {
            default = null;

            description = ''
              Timeout for waiting for upstream server's response headers.
            '';

            example = "5s";
            type = lib.types.nullOr lib.types.str;
          };

          urls = lib.mkOption {
            description = ''
              A list of URLs of upstream binary caches.
            '';

            example = [ "https://cache.nixos.org" ];
            type = lib.types.listOf lib.types.str;
          };
        };

      };

      logLevel = lib.mkOption {
        default = "info";

        description = ''
          Set the level for logging. Refer to
          <https://pkg.go.dev/github.com/rs/zerolog#readme-leveled-logging> for
          more information.
        '';

        type = lib.types.enum logLevels;
      };

      netrcFile = lib.mkOption {
        default = null;

        description = ''
          The path to netrc file for upstream authentication.
          When unspecified ncps will look for ``$HOME/.netrc`.
        '';

        example = "/etc/nix/netrc";
        type = lib.types.nullOr lib.types.path;
      };

      openTelemetry = {
        enable = lib.mkEnableOption "Enable OpenTelemetry logs, metrics, and tracing";

        grpcURL = lib.mkOption {
          default = null;

          description = ''
            Configure OpenTelemetry gRPC URL. Missing or "https" scheme enables
            secure gRPC, "insecure" otherwise. Omit to emit telemetry to
            stdout.
          '';

          type = lib.types.nullOr lib.types.str;
        };
      };

      prometheus.enable = lib.mkEnableOption "Enable Prometheus metrics endpoint at /metrics";

      server = {
        addr = lib.mkOption {
          default = ":8501";

          description = ''
            The address and port the server listens on.
          '';

          type = lib.types.str;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.xor (cfg.cache.databaseURL != null) (cfg.cache.databaseURLFile != null);
        message = "You must specify exactly one of config.ncps.cache.databaseURL or config.ncps.cache.databaseURLFile";
      }
      {
        assertion = cfg.cache.lru.schedule == null || cfg.cache.maxSize != null;
        message = "You must specify config.ncps.cache.lru.schedule when config.ncps.cache.maxSize is set";
      }
      {
        assertion =
          cfg.cache.redis == null || cfg.cache.redis.password == null || cfg.cache.redis.passwordFile == null;

        message = "You cannot specify both config.ncps.cache.redis.password and config.ncps.cache.redis.passwordFile";
      }
      {
        assertion = cfg.cache.lock.backend == "redis" -> cfg.cache.redis != null;
        message = "You must specify config.ncps.cache.redis when config.ncps.cache.lock.backend is set to 'redis'";
      }
      {
        assertion = cfg.cache.redis != null -> cfg.cache.lock.backend == "redis";
        message = "You must set config.ncps.cache.lock.backend to 'redis' when config.ncps.cache.redis is set";
      }
    ];

    systemd.services.ncps = {
      after = [ "network-online.target" ];
      description = "ncps binary cache proxy service";

      preStart = ''
        ${lib.optionalString (cfg.cache.databaseURLFile != null) ''
          export DATABASE_URL="$(cat "$CREDENTIALS_DIRECTORY/databaseURL")"
        ''}
        ${lib.optionalString (cfg.cache.databaseURL != null) ''
          export DATABASE_URL="${cfg.cache.databaseURL}"
        ''}
        echo ${cfg.package}/bin/dbmate-ncps up
        ${cfg.package}/bin/dbmate-ncps up
      '';

      serviceConfig = lib.mkMerge [
        {
          ExecStart = "${ncpsWrapper} serve";
          Group = "ncps";
          Restart = "on-failure";
          RuntimeDirectory = "ncps";
          User = "ncps";
        }

        # credentials for cache.secretKeyPath
        (lib.mkIf (cfg.cache.secretKeyPath != null) {
          LoadCredential = lib.singleton "secretKey:${cfg.cache.secretKeyPath}";
        })

        # credentials for cache.storage.s3 accessKeyIdPath and secretAccessKeyPath
        (lib.mkIf (cfg.cache.storage.s3 != null) {
          LoadCredential = [
            "s3AccessKeyId:${cfg.cache.storage.s3.accessKeyIdPath}"
            "s3SecretAccessKey:${cfg.cache.storage.s3.secretAccessKeyPath}"
          ];
        })

        # credentials for Redis
        (lib.mkIf (cfg.cache.redis != null && cfg.cache.redis.passwordFile != null) {
          LoadCredential = lib.singleton "redisPassword:${cfg.cache.redis.passwordFile}";
        })

        (lib.mkIf (cfg.cache.databaseURLFile != null) {
          LoadCredential = lib.singleton "databaseURL:${cfg.cache.databaseURLFile}";
        })

        # ensure permissions on required directories
        (lib.mkIf (cfg.cache.storage.s3 == null && cfg.cache.storage.local != "/var/lib/ncps") {
          ReadWritePaths = [ cfg.cache.storage.local ];
        })
        (lib.mkIf (cfg.cache.storage.s3 == null && cfg.cache.storage.local == "/var/lib/ncps") {
          StateDirectory = "ncps";
          StateDirectoryMode = "0700";
        })
        (lib.mkIf (cfg.cache.storage.s3 != null && isSqlite && lib.strings.hasPrefix "/var/lib/ncps" dbDir)
          {
            StateDirectory = "ncps";
            StateDirectoryMode = "0700";
          }
        )
        (lib.mkIf (isSqlite && !lib.strings.hasPrefix "/var/lib/ncps" dbDir) {
          ReadWritePaths = [ dbDir ];
        })
        (lib.mkIf (cfg.cache.tempPath != "/tmp") {
          ReadWritePaths = [ cfg.cache.tempPath ];
        })

        # Hardening
        {
          CapabilityBoundingSet = "";
          DeviceAllow = [ "" ];
          DevicePolicy = "closed";
          LimitNOFILE = 65536;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateNetwork = false;
          PrivateTmp = true;
          PrivateUsers = true;
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
          RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
            "~@resources"
          ];

          UMask = "0066";
        }
      ];

      unitConfig.RequiresMountsFor = lib.concatStringsSep " " (
        (lib.optional (cfg.cache.storage.s3 == null) "${cfg.cache.storage.local}")
        ++ (lib.optional isSqlite dbDir)
      );

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    systemd.tmpfiles.settings.ncps =
      let
        perms = {
          group = "ncps";
          mode = "0700";
          user = "ncps";
        };
      in
      lib.mkMerge [
        (lib.mkIf (cfg.cache.storage.s3 == null && cfg.cache.storage.local != "/var/lib/ncps") {
          "${cfg.cache.storage.local}".d = perms;
        })

        (lib.mkIf isSqlite { "${dbDir}".d = perms; })

        (lib.mkIf (cfg.cache.tempPath != "/tmp") { "${cfg.cache.tempPath}".d = perms; })
      ];

    users.groups.ncps = { };

    users.users.ncps = {
      group = "ncps";
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [
    kalbasit
    aciceri
  ];
}
