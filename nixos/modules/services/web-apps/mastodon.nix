{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.mastodon;
  opt = options.services.mastodon;

  # We only want to create a Redis and PostgreSQL databases if we're actually going to connect to it local.
  redisActuallyCreateLocally =
    cfg.redis.createLocally && (cfg.redis.host == "127.0.0.1" || cfg.redis.enableUnixSocket);
  databaseActuallyCreateLocally =
    cfg.database.createLocally && cfg.database.host == "/run/postgresql";

  env = {
    BOOTSNAP_CACHE_DIR = "/var/cache/mastodon/precompile";
    DB_HOST = cfg.database.host;
    DB_NAME = cfg.database.name;
    DB_USER = cfg.database.user;
    ES_ENABLED = if (cfg.elasticsearch.host != null) then "true" else "false";
    LD_PRELOAD = "${pkgs.jemalloc}/lib/libjemalloc.so";
    LOCAL_DOMAIN = cfg.localDomain;
    MAX_THREADS = toString cfg.webThreads;
    NODE_ENV = "production";
    PAPERCLIP_ROOT_PATH = "/var/lib/mastodon/public-system";
    PAPERCLIP_ROOT_URL = "/system";
    RAILS_ENV = "production";
    SMTP_FROM_ADDRESS = cfg.smtp.fromAddress;
    SMTP_PORT = toString cfg.smtp.port;
    SMTP_SERVER = cfg.smtp.host;
    TRUSTED_PROXY_IP = cfg.trustedProxy;
    # Concurrency mastodon-web
    WEB_CONCURRENCY = toString cfg.webProcesses;
  }
  // lib.optionalAttrs (cfg.redis.host != null) { REDIS_HOST = cfg.redis.host; }
  // lib.optionalAttrs (cfg.redis.port != null) { REDIS_PORT = toString cfg.redis.port; }
  // lib.optionalAttrs (cfg.redis.createLocally && cfg.redis.enableUnixSocket) {
    REDIS_URL = "unix://${config.services.redis.servers.mastodon.unixSocket}";
  }
  // lib.optionalAttrs (cfg.database.host != "/run/postgresql" && cfg.database.port != null) {
    DB_PORT = toString cfg.database.port;
  }
  // lib.optionalAttrs cfg.smtp.authenticate { SMTP_LOGIN = cfg.smtp.user; }
  // lib.optionalAttrs (cfg.elasticsearch.host != null) { ES_HOST = cfg.elasticsearch.host; }
  // lib.optionalAttrs (cfg.elasticsearch.host != null) { ES_PORT = toString cfg.elasticsearch.port; }
  // lib.optionalAttrs (cfg.elasticsearch.host != null && cfg.elasticsearch.prefix != null) {
    ES_PREFIX = cfg.elasticsearch.prefix;
  }
  // lib.optionalAttrs (cfg.elasticsearch.host != null) { ES_PRESET = cfg.elasticsearch.preset; }
  // lib.optionalAttrs (cfg.elasticsearch.user != null) { ES_USER = cfg.elasticsearch.user; }
  // cfg.extraConfig;

  systemCallsList = [
    "@cpu-emulation"
    "@debug"
    "@keyring"
    "@ipc"
    "@mount"
    "@obsolete"
    "@privileged"
    "@setuid"
  ];

  cfgService = {
    # Cache directory and mode
    CacheDirectory = "mastodon";
    CacheDirectoryMode = "0750";
    # Capabilities
    CapabilityBoundingSet = "";
    Group = cfg.group;
    LockPersonality = true;
    # Logs directory and mode
    LogsDirectory = "mastodon";
    LogsDirectoryMode = "0750";
    MemoryDenyWriteExecute = false;
    # Security
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateMounts = true;
    PrivateTmp = true;
    PrivateUsers = true;
    # Proc filesystem
    ProcSubset = "pid";
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    # Sandboxing
    ProtectSystem = "strict";
    RemoveIPC = true;

    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
      "AF_NETLINK"
    ];

    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    # State directory and mode
    StateDirectory = "mastodon";
    StateDirectoryMode = "0750";
    # System Call Filtering
    SystemCallArchitectures = "native";
    # Access write directories
    UMask = "0027";
    # User and group
    User = cfg.user;
    # Working directory
    WorkingDirectory = cfg.package;
  };

  # Units that all Mastodon units After= and Requires= on
  commonUnits =
    lib.optional redisActuallyCreateLocally "redis-mastodon.service"
    ++ lib.optional databaseActuallyCreateLocally "postgresql.target"
    ++ lib.optional cfg.automaticMigrations "mastodon-init-db.service";

  envFile = pkgs.writeText "mastodon.env" (
    lib.concatMapStrings (s: s + "\n") (
      lib.concatLists (
        lib.mapAttrsToList (name: value: lib.optional (value != null) ''${name}="${toString value}"'') env
      )
    )

  );

  mastodonTootctl =
    let
      sourceExtraEnv = lib.concatMapStrings (p: "source ${p}\n") cfg.extraEnvFiles;
    in
    pkgs.writeShellScriptBin "mastodon-tootctl" ''
      set -a
      export RAILS_ROOT="${cfg.package}"
      export HOME="/var/lib/mastodon"
      source "${envFile}"
      source /var/lib/mastodon/.secrets_env
      ${sourceExtraEnv}
      cd /var/lib/mastodon

      sudo=exec
      if [[ "$USER" != ${cfg.user} ]]; then
        sudo='exec /run/wrappers/bin/sudo -u ${cfg.user} --preserve-env'
      fi
      $sudo ${cfg.package}/bin/tootctl "$@"
    '';

  sidekiqUnits = lib.attrsets.mapAttrs' (
    name: processCfg:
    lib.nameValuePair "mastodon-sidekiq-${name}" (
      let
        jobClassArgs = toString (map (c: "-q ${c}") processCfg.jobClasses);
        jobClassLabel = toString ([ "" ] ++ processCfg.jobClasses);
        threads = toString (if processCfg.threads == null then cfg.sidekiqThreads else processCfg.threads);
      in
      {
        after = [
          "network.target"
          "mastodon-init-dirs.service"
        ]
        ++ commonUnits;

        description = "Mastodon sidekiq${jobClassLabel}";

        environment = env // {
          DB_POOL = threads;
          PORT = toString cfg.sidekiqPort;
        };

        path = with pkgs; [
          ffmpeg-headless
          file
        ];

        requires = [ "mastodon-init-dirs.service" ] ++ commonUnits;

        serviceConfig = {
          EnvironmentFile = [ "/var/lib/mastodon/.secrets_env" ] ++ cfg.extraEnvFiles;
          ExecStart = "${cfg.package}/bin/sidekiq ${jobClassArgs} -c ${threads} -r ${cfg.package}";
          LimitNOFILE = "1024000";
          Restart = "always";
          RestartSec = 20;

          # System Call Filtering
          SystemCallFilter = [
            ("~" + lib.concatStringsSep " " systemCallsList)
            "@chown"
            "pipe"
            "pipe2"
          ];

          WorkingDirectory = cfg.package;
        }
        // cfgService;

        wantedBy = [ "mastodon.target" ];
      }
    )
  ) cfg.sidekiqProcesses;

  streamingUnits = builtins.listToAttrs (
    map (i: {
      name = "mastodon-streaming-${toString i}";

      value = {
        after = [
          "network.target"
          "mastodon-init-dirs.service"
        ]
        ++ commonUnits;

        description = "Mastodon streaming ${toString i}";

        environment = env // {
          SOCKET = "/run/mastodon-streaming/streaming-${toString i}.socket";
        };

        requires = [ "mastodon-init-dirs.service" ] ++ commonUnits;

        serviceConfig = {
          EnvironmentFile = [ "/var/lib/mastodon/.secrets_env" ] ++ cfg.extraEnvFiles;
          ExecStart = "${cfg.package}/run-streaming.sh";
          Restart = "always";
          RestartSec = 20;
          # Runtime directory and mode
          RuntimeDirectory = "mastodon-streaming";
          RuntimeDirectoryMode = "0750";

          # System Call Filtering
          SystemCallFilter = [
            (
              "~"
              + lib.concatStringsSep " " (
                systemCallsList
                ++ [
                  "@memlock"
                  "@resources"
                ]
              )
            )
            "pipe"
            "pipe2"
          ];

          WorkingDirectory = cfg.package;
        }
        // cfgService;

        wantedBy = [
          "mastodon.target"
          "mastodon-streaming.target"
        ];
      };
    }) (lib.range 1 cfg.streamingProcesses)
  );

in
{

  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "mastodon"
      "streamingPort"
    ] "Mastodon currently doesn't support streaming via TCP ports. Please open a PR if you need this.")
    (lib.mkRemovedOptionModule [
      "services"
      "mastodon"
      "otpSecretFile"
    ] "The OTP_SECRET option was removed from Mastodon in version 4.4.0")
  ];

  options = {
    services.mastodon = {
      enable = lib.mkEnableOption "Mastodon, a federated social network server";
      package = lib.mkPackageOption pkgs "mastodon" { };

      activeRecordEncryptionDeterministicKeyFile = lib.mkOption {
        default = "/var/lib/mastodon/secrets/active-record-encryption-deterministic-key";

        description = ''
          This key must be set to enable the Active Record Encryption feature within
          Rails that Mastodon uses to encrypt and decrypt some database attributes.
          A new Active Record keys can be generated by running:

          `nix build -f '<nixpkgs>' mastodon; cd result; RAILS_ENV=production ./bin/rails db:encryption:init`

          If this file does not exist, it will be created with a new Active Record
          keys.
        '';

        type = lib.types.str;
      };

      activeRecordEncryptionKeyDerivationSaltFile = lib.mkOption {
        default = "/var/lib/mastodon/secrets/active-record-encryption-key-derivation-salt";

        description = ''
          This key must be set to enable the Active Record Encryption feature within
          Rails that Mastodon uses to encrypt and decrypt some database attributes.
          A new Active Record keys can be generated by running:

          `nix build -f '<nixpkgs>' mastodon; cd result; RAILS_ENV=production ./bin/rails db:encryption:init`

          If this file does not exist, it will be created with a new Active Record
          keys.
        '';

        type = lib.types.str;
      };

      activeRecordEncryptionPrimaryKeyFile = lib.mkOption {
        default = "/var/lib/mastodon/secrets/active-record-encryption-primary-key";

        description = ''
          This key must be set to enable the Active Record Encryption feature within
          Rails that Mastodon uses to encrypt and decrypt some database attributes.
          A new Active Record keys can be generated by running:

          `nix build -f '<nixpkgs>' mastodon; cd result; RAILS_ENV=production ./bin/rails db:encryption:init`

          If this file does not exist, it will be created with a new Active Record
          keys.
        '';

        type = lib.types.str;
      };

      automaticMigrations = lib.mkOption {
        default = true;

        description = ''
          Do automatic database migrations.
        '';

        type = lib.types.bool;
      };

      configureNginx = lib.mkOption {
        default = false;

        description = ''
          Configure nginx as a reverse proxy for mastodon.
          Note that this makes some assumptions on your setup, and sets settings that will
          affect other virtualHosts running on your nginx instance, if any.
          Alternatively you can configure a reverse-proxy of your choice to serve these paths:

          `/ -> ''${pkgs.mastodon}/public`

          `/ -> 127.0.0.1:{{ webPort }} `(If there was no file in the directory above.)

          `/system/ -> /var/lib/mastodon/public-system/`

          `/api/v1/streaming/ -> 127.0.0.1:{{ streamingPort }}`

          Make sure that websockets are forwarded properly. You might want to set up caching
          of some requests. Take a look at mastodon's provided nginx configuration at
          `https://github.com/mastodon/mastodon/blob/master/dist/nginx.conf`.
        '';

        type = lib.types.bool;
      };

      database = {
        createLocally = lib.mkOption {
          default = true;
          description = "Configure local PostgreSQL database server for Mastodon.";
          type = lib.types.bool;
        };

        host = lib.mkOption {
          default = "/run/postgresql";
          description = "Database host address or unix socket.";
          example = "192.168.23.42";
          type = lib.types.str;
        };

        name = lib.mkOption {
          default = "mastodon";
          description = "Database name.";
          type = lib.types.str;
        };

        passwordFile = lib.mkOption {
          default = null;

          description = ''
            A file containing the password corresponding to
            {option}`database.user`.
          '';

          example = "/var/lib/mastodon/secrets/db-password";
          type = lib.types.nullOr lib.types.path;
        };

        port = lib.mkOption {
          default = if cfg.database.createLocally then null else 5432;

          defaultText = lib.literalExpression ''
            if config.${opt.database.createLocally}
            then null
            else 5432
          '';

          description = "Database host port.";
          type = lib.types.nullOr lib.types.port;
        };

        user = lib.mkOption {
          default = "mastodon";
          description = "Database user.";
          type = lib.types.str;
        };
      };

      elasticsearch = {
        host = lib.mkOption {
          default = null;

          description = ''
            Elasticsearch host.
            If it is not null, Elasticsearch full text search will be enabled.
          '';

          type = lib.types.nullOr lib.types.str;
        };

        passwordFile = lib.mkOption {
          default = null;

          description = ''
            Path to file containing password for optionally authenticating with Elasticsearch.
          '';

          example = "/var/lib/mastodon/secrets/elasticsearch-password";
          type = lib.types.nullOr lib.types.path;
        };

        port = lib.mkOption {
          default = 9200;
          description = "Elasticsearch port.";
          type = lib.types.port;
        };

        prefix = lib.mkOption {
          default = null;

          description = ''
            If provided, adds a prefix to indexes in Elasticsearch. This allows to use the same
            Elasticsearch cluster between different projects or Mastodon servers.
          '';

          example = "mastodon";
          type = lib.types.nullOr lib.types.str;
        };

        preset = lib.mkOption {
          default = "single_node_cluster";

          description = ''
            It controls the ElasticSearch indices configuration (number of shards and replica).
          '';

          example = "large_cluster";

          type = lib.types.enum [
            "single_node_cluster"
            "small_cluster"
            "large_cluster"
          ];
        };

        user = lib.mkOption {
          default = null;
          description = "Used for optionally authenticating with Elasticsearch.";
          example = "elasticsearch-mastodon";
          type = lib.types.nullOr lib.types.str;
        };
      };

      enableUnixSocket = lib.mkOption {
        default = true;

        description = ''
          Instead of binding to an IP address like 127.0.0.1, you may bind to a Unix socket. This variable
          is process-specific, e.g. you need different values for every process, and it works for both web (Puma)
          processes and streaming API (Node.js) processes.
        '';

        type = lib.types.bool;
      };

      extraConfig = lib.mkOption {
        default = { };

        description = ''
          Extra environment variables to pass to all mastodon services.
        '';

        type = lib.types.attrs;
      };

      extraEnvFiles = lib.mkOption {
        default = [ ];

        description = ''
          Extra environment files to pass to all mastodon services. Useful for passing down environmental secrets.
        '';

        example = [ "/etc/mastodon/s3config.env" ];
        type = with lib.types; listOf path;
      };

      group = lib.mkOption {
        default = "mastodon";

        description = ''
          Group under which mastodon runs.
        '';

        type = lib.types.str;
      };

      localDomain = lib.mkOption {
        description = "The domain serving your Mastodon instance.";
        example = "social.example.org";
        type = lib.types.str;
      };

      mediaAutoRemove = {
        enable = lib.mkOption {
          default = true;

          description = ''
            Automatically remove remote media attachments and preview cards older than the configured amount of days.

            Recommended in <https://docs.joinmastodon.org/admin/setup/>.
          '';

          example = false;
          type = lib.types.bool;
        };

        olderThanDays = lib.mkOption {
          default = 30;

          description = ''
            How old remote media needs to be in order to be removed.
          '';

          example = 14;
          type = lib.types.int;
        };

        startAt = lib.mkOption {
          default = "daily";

          description = ''
            How often to remove remote media.

            The format is described in {manpage}`systemd.time(7)`.
          '';

          example = "hourly";
          type = lib.types.str;
        };
      };

      redis = {
        createLocally = lib.mkOption {
          default = true;
          description = "Configure local Redis server for Mastodon.";
          type = lib.types.bool;
        };

        enableUnixSocket = lib.mkOption {
          default = true;
          description = "Use Unix socket";
          type = lib.types.bool;
        };

        host = lib.mkOption {
          default = if cfg.redis.createLocally && !cfg.redis.enableUnixSocket then "127.0.0.1" else null;

          defaultText = lib.literalExpression ''
            if config.${opt.redis.createLocally} && !config.${opt.redis.enableUnixSocket} then "127.0.0.1" else null
          '';

          description = "Redis host.";
          type = lib.types.nullOr lib.types.str;
        };

        passwordFile = lib.mkOption {
          default = null;
          description = "A file containing the password for Redis database.";
          example = "/run/keys/mastodon-redis-password";
          type = lib.types.nullOr lib.types.path;
        };

        port = lib.mkOption {
          default = if cfg.redis.createLocally && !cfg.redis.enableUnixSocket then 31637 else null;

          defaultText = lib.literalExpression ''
            if config.${opt.redis.createLocally} && !config.${opt.redis.enableUnixSocket} then 31637 else null
          '';

          description = "Redis port.";
          type = lib.types.nullOr lib.types.port;
        };
      };

      secretKeyBaseFile = lib.mkOption {
        default = "/var/lib/mastodon/secrets/secret-key-base";

        description = ''
          Path to file containing the secret key base.
          A new secret key base can be generated by running:

          `nix build -f '<nixpkgs>' mastodon; cd result; bin/bundle exec rails secret`

          If this file does not exist, it will be created with a new secret key base.
        '';

        type = lib.types.str;
      };

      sidekiqPort = lib.mkOption {
        default = 55002;
        description = "TCP port used by the mastodon-sidekiq service.";
        type = lib.types.port;
      };

      sidekiqProcesses = lib.mkOption {
        default = {
          all = {
            jobClasses = [ ];
            threads = null;
          };
        };

        description = "How many Sidekiq processes should be used to handle background jobs, and which job classes they handle. *Read the [upstream documentation](https://docs.joinmastodon.org/admin/scaling/#sidekiq) before configuring this!*";

        example = {
          all = {
            jobClasses = [ ];
            threads = null;
          };

          default = {
            jobClasses = [ "default" ];
            threads = 10;
          };

          ingress = {
            jobClasses = [ "ingress" ];
            threads = 5;
          };

          push-pull = {
            jobClasses = [
              "push"
              "pull"
            ];

            threads = 5;
          };
        };

        type =
          with lib.types;
          attrsOf (submodule {
            options = {
              jobClasses = lib.mkOption {
                description = "If not empty, which job classes should be executed by this process. *Only one process should handle the 'scheduler' class. If left empty, this process will handle the 'scheduler' class.*";

                type = listOf (enum [
                  "default"
                  "fasp"
                  "push"
                  "pull"
                  "mailers"
                  "scheduler"
                  "ingress"
                ]);
              };

              threads = lib.mkOption {
                description = "Number of threads this process should use for executing jobs. If null, the configured `sidekiqThreads` are used.";
                type = nullOr int;
              };
            };
          });
      };

      sidekiqThreads = lib.mkOption {
        default = 25;
        description = "Worker threads used by the mastodon-sidekiq-all service. If `sidekiqProcesses` is configured and any processes specify null `threads`, this value is used.";
        type = lib.types.int;
      };

      smtp = {
        authenticate = lib.mkOption {
          default = false;
          description = "Authenticate with the SMTP server using username and password.";
          type = lib.types.bool;
        };

        createLocally = lib.mkOption {
          default = true;
          description = "Configure local Postfix SMTP server for Mastodon.";
          type = lib.types.bool;
        };

        fromAddress = lib.mkOption {
          description = ''"From" address used when sending Emails to users.'';
          type = lib.types.str;
        };

        host = lib.mkOption {
          default = "127.0.0.1";
          description = "SMTP host used when sending emails to users.";
          type = lib.types.str;
        };

        passwordFile = lib.mkOption {
          default = null;

          description = ''
            Path to file containing the SMTP password.
          '';

          example = "/var/lib/mastodon/secrets/smtp-password";
          type = lib.types.nullOr lib.types.path;
        };

        port = lib.mkOption {
          default = 25;
          description = "SMTP port used when sending emails to users.";
          type = lib.types.port;
        };

        user = lib.mkOption {
          default = null;
          description = "SMTP login name.";
          example = "mastodon@example.com";
          type = lib.types.nullOr lib.types.str;
        };
      };

      streamingProcesses = lib.mkOption {
        description = ''
          Number of processes used by the mastodon-streaming service.
          Please define this explicitly, recommended is the amount of your CPU cores minus one.
        '';

        example = 3;
        type = lib.types.ints.positive;
      };

      trustedProxy = lib.mkOption {
        default = "127.0.0.1";

        description = ''
          You need to set it to the IP from which your reverse proxy sends requests to Mastodon's web process,
          otherwise Mastodon will record the reverse proxy's own IP as the IP of all requests, which would be
          bad because IP addresses are used for important rate limits and security functions.
        '';

        type = lib.types.str;
      };

      user = lib.mkOption {
        default = "mastodon";

        description = ''
          User under which mastodon runs. If it is set to "mastodon",
          that user will be created, otherwise it should be set to the
          name of a user created elsewhere.
          In both cases, the `mastodon` package will be added to the user's package set
          and a tootctl wrapper to system packages that switches to the configured account
          and load the right environment.
        '';

        type = lib.types.str;
      };

      vapidPrivateKeyFile = lib.mkOption {
        default = "/var/lib/mastodon/secrets/vapid-private-key";

        description = ''
          Path to file containing the private key used for Web Push
          Voluntary Application Server Identification.  A new keypair can
          be generated by running:

          `nix build -f '<nixpkgs>' mastodon; cd result; bin/rake webpush:generate_keys`

          If this file does not exist, it will be created with a new
          private key.
        '';

        type = lib.types.str;
      };

      vapidPublicKeyFile = lib.mkOption {
        default = "/var/lib/mastodon/secrets/vapid-public-key";

        description = ''
          Path to file containing the public key used for Web Push
          Voluntary Application Server Identification.  A new keypair can
          be generated by running:

          `nix build -f '<nixpkgs>' mastodon; cd result; RAILS_ENV=production bin/rake webpush:generate_keys`

          If {option}`mastodon.vapidPrivateKeyFile`does not
          exist, it and this file will be created with a new keypair.
        '';

        type = lib.types.str;
      };

      webPort = lib.mkOption {
        default = 55001;
        description = "TCP port used by the mastodon-web service.";
        type = lib.types.port;
      };

      webProcesses = lib.mkOption {
        default = 2;
        description = "Processes used by the mastodon-web service.";
        type = lib.types.int;
      };

      webThreads = lib.mkOption {
        default = 5;
        description = "Threads per process used by the mastodon-web service.";
        type = lib.types.int;
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion =
              !redisActuallyCreateLocally -> (cfg.redis.host != "127.0.0.1" && cfg.redis.port != null);

            message = ''
              `services.mastodon.redis.host` and `services.mastodon.redis.port` need to be set if
                `services.mastodon.redis.createLocally` is not enabled.
            '';
          }
          {
            assertion =
              redisActuallyCreateLocally
              -> (!cfg.redis.enableUnixSocket || (cfg.redis.host == null && cfg.redis.port == null));

            message = ''
              `services.mastodon.redis.enableUnixSocket` needs to be disabled if
                `services.mastodon.redis.host` and `services.mastodon.redis.port` is used.
            '';
          }
          {
            assertion =
              redisActuallyCreateLocally -> (!cfg.redis.enableUnixSocket || cfg.redis.passwordFile == null);

            message = ''
              <option>services.mastodon.redis.enableUnixSocket</option> needs to be disabled if
                <option>services.mastodon.redis.passwordFile</option> is used.
            '';
          }
          {
            assertion =
              databaseActuallyCreateLocally
              -> (cfg.user == cfg.database.user && cfg.database.user == cfg.database.name);

            message = ''
              For local automatic database provisioning (services.mastodon.database.createLocally == true) with peer
                authentication (services.mastodon.database.host == "/run/postgresql") to work services.mastodon.user
                and services.mastodon.database.user must be identical.
            '';
          }
          {
            assertion = !databaseActuallyCreateLocally -> (cfg.database.host != "/run/postgresql");

            message = ''
              <option>services.mastodon.database.host</option> needs to be set if
                <option>services.mastodon.database.createLocally</option> is not enabled.
            '';
          }
          {
            assertion = cfg.smtp.authenticate -> (cfg.smtp.user != null);

            message = ''
              <option>services.mastodon.smtp.user</option> needs to be set if
                <option>services.mastodon.smtp.authenticate</option> is enabled.
            '';
          }
          {
            assertion = cfg.smtp.authenticate -> (cfg.smtp.passwordFile != null);

            message = ''
              <option>services.mastodon.smtp.passwordFile</option> needs to be set if
                <option>services.mastodon.smtp.authenticate</option> is enabled.
            '';
          }
          {
            assertion =
              1 == (lib.count (x: x) (
                lib.mapAttrsToList (
                  _: v: builtins.elem "scheduler" v.jobClasses || v.jobClasses == [ ]
                ) cfg.sidekiqProcesses
              ));

            message = "There must be exactly one Sidekiq queue in services.mastodon.sidekiqProcesses with jobClass \"scheduler\".";
          }
          {
            assertion =
              databaseActuallyCreateLocally
              -> lib.versionAtLeast config.services.postgresql.finalPackage.version "14";

            message = "Mastodon requires at least PostgreSQL 14.";
          }
        ];

        environment.systemPackages = [ mastodonTootctl ];

        services.nginx = lib.mkIf cfg.configureNginx {
          enable = true;
          recommendedProxySettings = true; # required for redirections to work

          upstreams.mastodon-streaming = {
            extraConfig = ''
              least_conn;
            '';

            servers = builtins.listToAttrs (
              map (i: {
                name = "unix:/run/mastodon-streaming/streaming-${toString i}.socket";
                value = { };
              }) (lib.range 1 cfg.streamingProcesses)
            );
          };

          virtualHosts."${cfg.localDomain}" = {
            enableACME = lib.mkDefault true;
            # mastodon only supports https, but you can override this if you offload tls elsewhere.
            forceSSL = lib.mkDefault true;

            locations."/" = {
              tryFiles = "$uri @proxy";
            };

            locations."/api/v1/streaming" = {
              proxyPass = "http://mastodon-streaming";
              proxyWebsockets = true;
            };

            locations."/system/".alias = "/var/lib/mastodon/public-system/";

            locations."@proxy" = {
              proxyPass = (
                if cfg.enableUnixSocket then
                  "http://unix:/run/mastodon-web/web.socket"
                else
                  "http://127.0.0.1:${toString cfg.webPort}"
              );

              proxyWebsockets = true;
            };

            root = "${cfg.package}/public/";
          };
        };

        services.postfix = lib.mkIf (cfg.smtp.createLocally && cfg.smtp.host == "127.0.0.1") {
          enable = true;
          settings.main.myhostname = lib.mkDefault "${cfg.localDomain}";
        };

        services.postgresql = lib.mkIf databaseActuallyCreateLocally {
          enable = true;
          ensureDatabases = [ cfg.database.name ];

          ensureUsers = [
            {
              ensureDBOwnership = true;
              name = cfg.database.name;
            }
          ];
        };

        services.redis.servers.mastodon = lib.mkIf redisActuallyCreateLocally (
          lib.mkMerge [
            {
              enable = true;
            }
            (lib.mkIf (!cfg.redis.enableUnixSocket) {
              port = cfg.redis.port;
            })
          ]
        );

        systemd.services.mastodon-init-db = lib.mkIf cfg.automaticMigrations {
          after = [
            "network.target"
            "mastodon-init-dirs.service"
          ]
          ++ lib.optional databaseActuallyCreateLocally "postgresql.target";

          environment =
            env
            // lib.optionalAttrs (!databaseActuallyCreateLocally) {
              PGDATABASE = cfg.database.name;
              PGHOST = cfg.database.host;
              PGPORT = toString cfg.database.port;
              PGUSER = cfg.database.user;
            };

          path = [
            cfg.package
            (if databaseActuallyCreateLocally then config.services.postgresql.package else pkgs.postgresql)
          ];

          requires = [
            "mastodon-init-dirs.service"
          ]
          ++ lib.optional databaseActuallyCreateLocally "postgresql.target";

          script =
            lib.optionalString (!databaseActuallyCreateLocally) ''
              umask 077
              export PGPASSWORD="$(cat '${cfg.database.passwordFile}')"
            ''
            + ''
              result="$(psql -t --csv -c \
                  "select count(*) from pg_class c \
                  join pg_namespace s on s.oid = c.relnamespace \
                  where s.nspname not in ('pg_catalog', 'pg_toast', 'information_schema') \
                  and s.nspname not like 'pg_temp%';")" || error_code=$?
              if [ "''${error_code:-0}" -ne 0 ]; then
                echo "Failure checking if database is seeded. psql gave exit code $error_code"
                exit "$error_code"
              fi
              if [ "$result" -eq 0 ]; then
                echo "Seeding database"
                SAFETY_ASSURED=1 rails db:schema:load
                rails db:seed
              else
                echo "Migrating database (this might be a noop)"
                rails db:migrate
              fi
            ''
            + lib.optionalString (!databaseActuallyCreateLocally) ''
              unset PGPASSWORD
            '';

          serviceConfig = {
            EnvironmentFile = [ "/var/lib/mastodon/.secrets_env" ] ++ cfg.extraEnvFiles;

            # System Call Filtering
            SystemCallFilter = [
              ("~" + lib.concatStringsSep " " (systemCallsList ++ [ "@resources" ]))
              "@chown"
              "pipe"
              "pipe2"
            ];

            Type = "oneshot";
            WorkingDirectory = cfg.package;
          }
          // cfgService;
        };

        systemd.services.mastodon-init-dirs = {
          after = [ "network.target" ];
          environment = env;

          script = ''
            umask 077

            if ! test -d /var/cache/mastodon/precompile; then
              ${cfg.package}/bin/bundle exec bootsnap precompile --gemfile ${cfg.package}/app ${cfg.package}/lib
            fi
            if ! test -f ${cfg.activeRecordEncryptionDeterministicKeyFile}; then
              mkdir -p $(dirname ${cfg.activeRecordEncryptionDeterministicKeyFile})
              bin/rails db:encryption:init | grep --only-matching "ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=[^ ]\+" | sed 's/^ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=//' > ${cfg.activeRecordEncryptionDeterministicKeyFile}
            fi
            if ! test -f ${cfg.activeRecordEncryptionKeyDerivationSaltFile}; then
              mkdir -p $(dirname ${cfg.activeRecordEncryptionKeyDerivationSaltFile})
              bin/rails db:encryption:init | grep --only-matching "ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=[^ ]\+" | sed 's/^ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=//' > ${cfg.activeRecordEncryptionKeyDerivationSaltFile}
            fi
            if ! test -f ${cfg.activeRecordEncryptionPrimaryKeyFile}; then
              mkdir -p $(dirname ${cfg.activeRecordEncryptionPrimaryKeyFile})
              bin/rails db:encryption:init | grep --only-matching "ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=[^ ]\+" | sed 's/^ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=//' > ${cfg.activeRecordEncryptionPrimaryKeyFile}
            fi
            if ! test -f ${cfg.secretKeyBaseFile}; then
              mkdir -p $(dirname ${cfg.secretKeyBaseFile})
              bin/bundle exec rails secret > ${cfg.secretKeyBaseFile}
            fi
            if ! test -f ${cfg.vapidPrivateKeyFile}; then
              mkdir -p $(dirname ${cfg.vapidPrivateKeyFile}) $(dirname ${cfg.vapidPublicKeyFile})
              keypair=$(bin/rake webpush:generate_keys)
              echo $keypair | grep --only-matching "Private -> [^ ]\+" | sed 's/^Private -> //' > ${cfg.vapidPrivateKeyFile}
              echo $keypair | grep --only-matching "Public -> [^ ]\+" | sed 's/^Public -> //' > ${cfg.vapidPublicKeyFile}
            fi

            cat > /var/lib/mastodon/.secrets_env <<EOF
            ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY="$(cat ${cfg.activeRecordEncryptionDeterministicKeyFile})"
            ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT="$(cat ${cfg.activeRecordEncryptionKeyDerivationSaltFile})"
            ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY="$(cat ${cfg.activeRecordEncryptionPrimaryKeyFile})"
            SECRET_KEY_BASE="$(cat ${cfg.secretKeyBaseFile})"
            VAPID_PRIVATE_KEY="$(cat ${cfg.vapidPrivateKeyFile})"
            VAPID_PUBLIC_KEY="$(cat ${cfg.vapidPublicKeyFile})"
          ''
          + lib.optionalString (cfg.redis.passwordFile != null) ''
            REDIS_PASSWORD="$(cat ${cfg.redis.passwordFile})"
          ''
          + lib.optionalString (cfg.database.passwordFile != null) ''
            DB_PASS="$(cat ${cfg.database.passwordFile})"
          ''
          + lib.optionalString cfg.smtp.authenticate ''
            SMTP_PASSWORD="$(cat ${cfg.smtp.passwordFile})"
          ''
          + lib.optionalString (cfg.elasticsearch.passwordFile != null) ''
            ES_PASS="$(cat ${cfg.elasticsearch.passwordFile})"
          ''
          + ''
            EOF
          '';

          serviceConfig = {
            SyslogIdentifier = "mastodon-init-dirs";

            # System Call Filtering
            SystemCallFilter = [
              ("~" + lib.concatStringsSep " " (systemCallsList ++ [ "@resources" ]))
              "@chown"
              "pipe"
              "pipe2"
            ];

            Type = "oneshot";
          }
          // cfgService;
        };

        systemd.services.mastodon-media-auto-remove = lib.mkIf cfg.mediaAutoRemove.enable {
          description = "Mastodon media auto remove";
          environment = env;

          script =
            let
              olderThanDays = toString cfg.mediaAutoRemove.olderThanDays;
            in
            ''
              ${cfg.package}/bin/tootctl media remove --days=${olderThanDays}
              ${cfg.package}/bin/tootctl preview_cards remove --days=${olderThanDays}
            '';

          serviceConfig = {
            EnvironmentFile = [ "/var/lib/mastodon/.secrets_env" ] ++ cfg.extraEnvFiles;
            Type = "oneshot";
          }
          // cfgService;

          startAt = cfg.mediaAutoRemove.startAt;
        };

        systemd.services.mastodon-web = {
          after = [
            "network.target"
            "mastodon-init-dirs.service"
          ]
          ++ commonUnits;

          description = "Mastodon web";

          environment =
            env
            // (
              if cfg.enableUnixSocket then
                { SOCKET = "/run/mastodon-web/web.socket"; }
              else
                { PORT = toString cfg.webPort; }
            );

          path = with pkgs; [
            ffmpeg-headless
            file
          ];

          requires = [ "mastodon-init-dirs.service" ] ++ commonUnits;

          serviceConfig = {
            EnvironmentFile = [ "/var/lib/mastodon/.secrets_env" ] ++ cfg.extraEnvFiles;
            ExecStart = "${cfg.package}/bin/puma -C config/puma.rb";
            Restart = "always";
            RestartSec = 20;
            # Runtime directory and mode
            RuntimeDirectory = "mastodon-web";
            RuntimeDirectoryMode = "0750";

            # System Call Filtering
            SystemCallFilter = [
              ("~" + lib.concatStringsSep " " systemCallsList)
              "@chown"
              "pipe"
              "pipe2"
            ];

            WorkingDirectory = cfg.package;
          }
          // cfgService;

          wantedBy = [ "mastodon.target" ];
        };

        systemd.targets.mastodon = {
          after = [ "network.target" ];
          description = "Target for all Mastodon services";
          wantedBy = [ "multi-user.target" ];
        };

        systemd.targets.mastodon-streaming = {
          after = [ "network.target" ];
          description = "Target for all Mastodon streaming services";

          wantedBy = [
            "multi-user.target"
            "mastodon.target"
          ];
        };

        users.groups.${cfg.group}.members = lib.optional cfg.configureNginx config.services.nginx.user;

        users.users = lib.mkMerge [
          (lib.mkIf (cfg.user == "mastodon") {
            mastodon = {
              inherit (cfg) group;
              home = cfg.package;
              isSystemUser = true;
            };
          })
          (lib.attrsets.setAttrByPath [ cfg.user "packages" ] [ cfg.package ])
          (lib.mkIf (cfg.redis.createLocally && cfg.redis.enableUnixSocket) {
            ${config.services.mastodon.user}.extraGroups = [ "redis-mastodon" ];
          })
        ];
      }
      {
        systemd.services = lib.mkMerge [
          sidekiqUnits
          streamingUnits
        ];
      }
    ]
  );

  meta.maintainers = with lib.maintainers; [
    happy-river
    erictapen
  ];

}
