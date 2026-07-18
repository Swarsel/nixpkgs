{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.dawarich;
  opt = options.services.dawarich;

  dataDir = "/var/lib/dawarich";

  isRedisUnixSocket = lib.hasPrefix "/" cfg.redis.host;

  redisEnv =
    if isRedisUnixSocket then
      {
        REDIS_URL = "unix://${config.services.redis.servers.dawarich.unixSocket}";
      }
    else
      {
        # Does not support passwords, but upstream does not provide an adequate env variable
        # Perhaps patch or make a PR upstream in the future
        REDIS_URL = "redis://${cfg.redis.host}:${toString cfg.redis.port}";
      };

  env = {
    APPLICATION_HOSTS = "127.0.0.1,::1,${cfg.localDomain}";
    APPLICATION_PROTOCOL = "http";
    BOOTSNAP_CACHE_DIR = "/var/cache/dawarich/precompile";
    BUNDLE_USER_HOME = "/tmp/bundle"; # will use private tmp inside systemd unit
    DATABASE_HOST = cfg.database.host;
    DATABASE_NAME = cfg.database.name;
    DATABASE_PORT = toString cfg.database.port;
    DATABASE_USER = cfg.database.user;
    DOMAIN = cfg.localDomain;
    LD_PRELOAD = "${lib.getLib pkgs.jemalloc}/lib/libjemalloc.so";
    NODE_ENV = "production";
    PORT = toString cfg.webPort;
    RAILS_ENV = "production";
    SELF_HOSTED = "true";
    SMTP_FROM = cfg.smtp.fromAddress;
    SMTP_PORT = toString cfg.smtp.port;
    SMTP_SERVER = cfg.smtp.host;
    SMTP_USERNAME = cfg.smtp.user;
    STORE_GEODATA = "true";
    TIME_ZONE = config.time.timeZone; # otherwise upstream forces it to Europe/London
  }
  // redisEnv
  // cfg.environment;

  systemCallFilter =
    let
      allowedSystemCalls = [
        "@cpu-emulation"
        "@debug"
        "@keyring"
        "@ipc"
        "@mount"
        "@obsolete"
        "@privileged"
        "@setuid"
      ];
    in
    [
      ("~" + lib.concatStringsSep " " allowedSystemCalls)
      "@chown"
      "pipe"
      "pipe2"
    ];

  cfgService = {
    CacheDirectory = "dawarich";
    CacheDirectoryMode = "0750";
    CapabilityBoundingSet = "";
    Group = cfg.group;
    LockPersonality = true;
    LogsDirectory = "dawarich";
    LogsDirectoryMode = "0750";
    MemoryDenyWriteExecute = false;
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateMounts = true;
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
    StateDirectory = "dawarich";
    StateDirectoryMode = "0750";

    # ensure permissions to connect to the redis socket
    SupplementaryGroups = lib.mkIf (cfg.redis.createLocally && isRedisUnixSocket) [
      config.services.redis.servers.dawarich.group
    ];

    SystemCallArchitectures = "native";
    SystemCallFilter = systemCallFilter;
    UMask = "0027";
    User = cfg.user;
    WorkingDirectory = cfg.package;
  };

  # Units that all Dawarich units After= and Requires= on
  commonUnits =
    lib.optional cfg.redis.createLocally "redis-dawarich.service"
    ++ lib.optional cfg.database.createLocally "postgresql.target"
    ++ lib.optional cfg.automaticMigrations "dawarich-init-db.service";

  defaultSecretKeyBaseFile = "${dataDir}/secrets/secret-key-base";
  needsGenCredentialsUnit = cfg.secretKeyBaseFile == null;
  credentials = {
    SECRET_KEY_BASE = lib.defaultTo defaultSecretKeyBaseFile cfg.secretKeyBaseFile;
  }
  // lib.optionalAttrs (cfg.database.passwordFile != null) {
    DATABASE_PASSWORD = cfg.database.passwordFile;
  }
  // lib.optionalAttrs (cfg.smtp.passwordFile != null) {
    SMTP_PASSWORD = cfg.smtp.passwordFile;
  };
  loadCredentialsIntoEnv = lib.concatMapAttrsStringSep "\n" (
    name: _: ''export ${name}="$(systemd-creds cat ${name})"''
  ) credentials;
  loadCredentials = lib.mapAttrsToList (name: path: "${name}:${path}") credentials;

  dawarichRails = pkgs.writeShellApplication {
    name = "dawarich-rails";

    text =
      let
        sourceExtraEnv = lib.concatMapStrings (p: "source ${p}\n") cfg.extraEnvFiles;
        command = pkgs.writeShellScript "dawarich-rails-unwrapped" ''
          ${sourceExtraEnv}
          ${loadCredentialsIntoEnv}
          export RAILS_ROOT="${cfg.package}"
          exec ${lib.getExe' cfg.package "rails"} "$@"
        '';
        env' = lib.filterAttrs (_: value: value != null) env;
        supplementaryGroups = lib.optionalString (cfg.redis.createLocally && isRedisUnixSocket) (
          lib.escapeShellArg "--property=SupplementaryGroups=${config.services.redis.servers.dawarich.group}"
        );
      in
      ''
        exec ${lib.getExe' config.systemd.package "systemd-run"} \
          ${
            lib.escapeShellArgs (map (credential: "--property=LoadCredential=${credential}") loadCredentials)
          } \
          ${
            lib.escapeShellArgs (lib.mapAttrsToList (name: value: "--setenv=${name}=${toString value}") env')
          } \
          --uid=${lib.escapeShellArg cfg.user} \
          --gid=${lib.escapeShellArg cfg.group} \
          ${supplementaryGroups} \
          --working-directory=${lib.escapeShellArg cfg.package} \
          --property=PrivateTmp=yes \
          --pty \
          --wait \
          --collect \
          --service-type=exec \
          --quiet \
          -- \
          ${command} "$@"
      '';
  };
  dawarichConsole = pkgs.writeShellScriptBin "dawarich-console" ''
    exec ${lib.getExe dawarichRails} console "$@"
  '';

  sidekiqUnits = lib.attrsets.mapAttrs' (
    name: processCfg:
    lib.nameValuePair "dawarich-sidekiq-${name}" (
      let
        jobClassArgs = lib.concatMapStringsSep " " (c: "-q ${c}") processCfg.jobClasses;
        jobClassLabel = lib.optionalString (
          processCfg.jobClasses != [ ]
        ) " (${lib.concatStringsSep ", " processCfg.jobClasses})";
        threads = toString (if processCfg.threads == null then cfg.sidekiqThreads else processCfg.threads);
      in
      {
        after = [
          "network.target"
        ]
        ++ lib.optional needsGenCredentialsUnit "dawarich-init-credentials.service"
        ++ commonUnits;

        description = "Dawarich sidekiq${jobClassLabel}";

        environment = env // {
          RAILS_MAX_THREADS = threads;
        };

        requires = lib.optional needsGenCredentialsUnit "dawarich-init-credentials.service" ++ commonUnits;

        script = ''
          ${loadCredentialsIntoEnv}

          ${lib.getExe' cfg.package "sidekiq"} ${jobClassArgs} -c ${threads} -r ${cfg.package}
        '';

        serviceConfig = {
          EnvironmentFile = cfg.extraEnvFiles;
          LimitNOFILE = "1024000";
          LoadCredential = loadCredentials;
          Restart = "always";
          RestartSec = 20;
        }
        // cfgService;

        wantedBy = [ "dawarich.target" ];
      }
    )
  ) cfg.sidekiqProcesses;

in
{

  options = {
    services.dawarich = {
      enable = lib.mkEnableOption "Dawarich, a self-hostable alternative to Google Location History";
      package = lib.mkPackageOption pkgs "dawarich" { };

      automaticMigrations = lib.mkOption {
        default = true;
        description = "Whether to perform database migrations automatically";
        type = lib.types.bool;
      };

      configureNginx = lib.mkOption {
        default = true;

        description = ''
          Configure nginx as a reverse proxy for dawarich.
          Alternatively you can configure a reverse-proxy of your choice to serve these paths:

          `/ -> ''${pkgs.dawarich}/public`

          `/ -> 127.0.0.1:{{ webPort }} `(If there was no file in the directory above.)

          Make sure that websockets are forwarded properly. You might want to set up caching
          of some requests. Take a look at dawarich's provided reverse proxy configurations at
          `https://dawarich.app/docs/tutorials/reverse-proxy`.
        '';

        type = lib.types.bool;
      };

      database = {
        createLocally = lib.mkOption {
          default = true;

          description = ''
            Whether to configure a local PostgreSQL server and database for Dawarich.
            The connection is performed via Unix sockets.
          '';

          type = lib.types.bool;
        };

        host = lib.mkOption {
          default = "/run/postgresql";
          description = "Hostname or address of the postgresql server. If an absolute path is given here, it will be interpreted as a unix socket path.";
          example = "127.0.0.1";
          type = lib.types.str;
        };

        name = lib.mkOption {
          default = "dawarich";
          description = "The name of the dawarich database.";
          type = lib.types.str;
        };

        passwordFile = lib.mkOption {
          default = null;

          description = ''
            A file containing the password corresponding to {option}`${opt.database.user}`.
          '';

          example = "/run/keys/dawarich-db-password";
          type = lib.types.nullOr lib.types.path;
        };

        port = lib.mkOption {
          default = 5432;
          description = "Port of the postgresql server.";
          type = lib.types.nullOr lib.types.port;
        };

        user = lib.mkOption {
          default = "dawarich";
          description = "The database user for dawarich.";
          type = lib.types.str;
        };
      };

      environment = lib.mkOption {
        default = { };

        description = ''
          Extra environment variables to pass to all dawarich services.
        '';

        type =
          with lib.types;
          attrsOf (
            nullOr (oneOf [
              str
              path
              package
            ])
          );
      };

      extraEnvFiles = lib.mkOption {
        default = [ ];

        description = ''
          Extra environment files to pass to all Dawarich services. Useful for passing down environment secrets.
        '';

        example = [ "/etc/dawarich/secret.env" ];
        type = with lib.types; listOf path;
      };

      group = lib.mkOption {
        default = "dawarich";

        description = ''
          Group under which dawarich runs.
        '';

        type = lib.types.str;
      };

      localDomain = lib.mkOption {
        description = "The domain serving your Dawarich instance.";
        example = "dawarich.example.org";
        type = lib.types.str;
      };

      redis = {
        createLocally = lib.mkOption {
          default = true;

          description = ''
            Whether to configure a local Redis server for Dawarich.
            The connection is performed via Unix sockets by default,
            but that can be changed by configuring {option}`${opt.redis.host}` and {option}`${opt.redis.port}`.
          '';

          type = lib.types.bool;
        };

        host = lib.mkOption {
          default = config.services.redis.servers.dawarich.unixSocket;
          defaultText = lib.literalExpression "config.services.redis.servers.dawarich.unixSocket";
          description = "The redis host Dawarich will connect to.";
          type = lib.types.str;
        };

        port = lib.mkOption {
          default = 0;
          description = "The port of the redis server Dawarich will connect to. Set to zero to disable TCP and use Unix sockets instead.";
          type = lib.types.port;
        };
      };

      secretKeyBaseFile = lib.mkOption {
        default = null;

        description = ''
          Path to file containing the secret key base.
          A new secret key base can be generated by running:

          `nix build -f '<nixpkgs>' dawarich; cd result; bin/bundle exec rails secret`

          This file is loaded using systemd credentials, and therefore does not need to be
          owned by the dawarich user.

          If this option is null, it will be created at ${defaultSecretKeyBaseFile}
          with a new secret key base.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      sidekiqProcesses = lib.mkOption {
        default = {
          all = {
            jobClasses = [ ];
            threads = null;
          };
        };

        description = ''
          How many Sidekiq processes should be used to handle background jobs, and which job classes they handle.
          Can be used to [speed up](https://dawarich.app/docs/FAQ/#how-to-speed-up-the-import-process) the import process.
        '';

        example = {
          all = {
            jobClasses = [ ];
            threads = null;
          };

          geocoding = {
            jobClasses = [ "reverse_geocoding" ];
            threads = 10;
          };
        };

        type =
          with lib.types;
          attrsOf (submodule {
            options = {
              jobClasses = lib.mkOption {
                description = ''
                  If not empty, which job classes should be executed by this process.
                  *If left empty, all job classes will be executed by this process.*
                '';

                # https://github.com/Freika/dawarich/blob/0.37.2/config/sidekiq.yml
                type = listOf (enum [
                  "app_version_checking"
                  "archival"
                  "cache"
                  "data_migrations"
                  "default"
                  "digests"
                  "exports"
                  "families"
                  "imports"
                  "mailers"
                  "places"
                  "points"
                  "reverse_geocoding"
                  "stats"
                  "tracks"
                  "trips"
                  "visit_suggesting"
                ]);
              };

              threads = lib.mkOption {
                description = ''
                  Number of threads this process should use for executing jobs.
                  If null, the configured `sidekiqThreads` are used.
                '';

                type = nullOr int;
              };
            };
          });
      };

      sidekiqThreads = lib.mkOption {
        default = 5;

        description = ''
          Worker threads used by the dawarich-sidekiq-all service.
          If `sidekiqProcesses` is configured and any processes specify null `threads`, this value is used.
        '';

        type = lib.types.int;
      };

      smtp = {
        fromAddress = lib.mkOption {
          default = null;
          description = ''"From" address used when sending emails to users.'';
          example = "dawarich@example.com";
          type = lib.types.nullOr lib.types.str;
        };

        host = lib.mkOption {
          default = null;
          description = "SMTP host used when sending emails to users.";
          type = lib.types.nullOr lib.types.str;
        };

        passwordFile = lib.mkOption {
          default = null;

          description = ''
            Path to file containing the SMTP password.
          '';

          example = "/run/keys/dawarich-smtp-password";
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
          example = "dawarich@example.com";
          type = lib.types.nullOr lib.types.str;
        };
      };

      user = lib.mkOption {
        default = "dawarich";

        description = ''
          User under which dawarich runs. If it is set to "dawarich",
          that user will be created, otherwise it should be set to the
          name of a user created elsewhere.
        '';

        type = lib.types.str;
      };

      webPort = lib.mkOption {
        default = 3000;
        description = "TCP port used by the dawarich web service.";
        type = lib.types.port;
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = !isRedisUnixSocket -> cfg.redis.port != 0;

            message = ''
              `services.dawarich.redis.port` needs to be configured if `services.dawarich.redis.host` is not a unix socket.
            '';
          }
        ];

        environment.systemPackages = [
          dawarichConsole
          dawarichRails
        ];

        services.nginx = lib.mkIf cfg.configureNginx {
          enable = true;

          virtualHosts."${cfg.localDomain}" = {
            locations."/" = {
              tryFiles = "$uri @proxy";
            };

            locations."@proxy" = {
              proxyPass = "http://127.0.0.1:${toString cfg.webPort}";
              proxyWebsockets = true;
              recommendedProxySettings = true;
            };

            root = "${cfg.package}/public/";
          };
        };

        services.postgresql = lib.mkIf cfg.database.createLocally {
          enable = true;
          ensureDatabases = [ cfg.database.name ];

          ensureUsers = [
            {
              inherit (cfg.database) name;
              ensureDBOwnership = true;
            }
          ];

          extensions = ps: with ps; [ postgis ];
        };

        services.redis.servers = lib.mkIf cfg.redis.createLocally {
          dawarich = {
            enable = true;
            bind = lib.mkIf (!isRedisUnixSocket) cfg.redis.host;
            port = cfg.redis.port;
          };
        };

        systemd.services.dawarich-init-credentials = lib.mkIf needsGenCredentialsUnit {
          after = [ "network.target" ];
          environment = env;

          script = ''
            umask 077
          ''
          + lib.optionalString (cfg.secretKeyBaseFile == null) ''
            if ! test -f ${defaultSecretKeyBaseFile}; then
              mkdir -p $(dirname ${defaultSecretKeyBaseFile})
              bin/bundle exec rails secret > ${defaultSecretKeyBaseFile}
            fi
          '';

          serviceConfig = {
            SyslogIdentifier = "dawarich-init-dirs";
            # System Call Filtering
            SystemCallFilter = [ "~@resources" ] ++ systemCallFilter;
            Type = "oneshot";
          }
          // cfgService;
        };

        systemd.services.dawarich-init-db = lib.mkIf cfg.automaticMigrations {
          # both postgres and redis are needed for the migrations to work
          after = [
            "network.target"
          ]
          ++ lib.optional needsGenCredentialsUnit "dawarich-init-credentials.service"
          ++ lib.optional cfg.database.createLocally "postgresql.target"
          ++ lib.optional cfg.redis.createLocally "redis-dawarich.service";

          environment = env;
          path = [ cfg.package ];

          requires =
            lib.optional needsGenCredentialsUnit "dawarich-init-credentials.service"
            ++ lib.optional cfg.database.createLocally "postgresql.target"
            ++ lib.optional cfg.redis.createLocally "redis-dawarich.service";

          script = ''
            ${loadCredentialsIntoEnv}

            # Run primary database migrations first (needed before other migrations)
            echo "Running primary database migrations..."
            rails db:migrate

            # Run data migrations
            echo "Running DATA migrations..."
            rake data:migrate

            echo "Running seeds..."
            rails db:seed
          '';

          serviceConfig = {
            EnvironmentFile = cfg.extraEnvFiles;
            LoadCredential = loadCredentials;
            # System Call Filtering
            SystemCallFilter = [ "~@resources" ] ++ systemCallFilter;
            Type = "oneshot";
            WorkingDirectory = cfg.package;
          }
          // cfgService;
        };

        systemd.services.dawarich-web = {
          after = [
            "network.target"
          ]
          ++ lib.optional needsGenCredentialsUnit "dawarich-init-credentials.service"
          ++ commonUnits;

          description = "Dawarich web";
          environment = env;
          requires = lib.optional needsGenCredentialsUnit "dawarich-init-credentials.service" ++ commonUnits;

          script = ''
            ${loadCredentialsIntoEnv}

            ${lib.getExe' cfg.package "rails"} server
          '';

          serviceConfig = {
            EnvironmentFile = cfg.extraEnvFiles;
            LoadCredential = loadCredentials;
            Restart = "always";
            RestartSec = 20;
            # Runtime directory and mode
            RuntimeDirectory = "dawarich-web";
            RuntimeDirectoryMode = "0750";
            WorkingDirectory = cfg.package;
          }
          // cfgService;

          wantedBy = [ "dawarich.target" ];
        };

        systemd.services.postgresql-setup.serviceConfig.ExecStartPost =
          let
            # https://github.com/Freika/dawarich/blob/0.30.6/db/schema.rb#L15-L16
            # https://postgis.net/documentation/getting_started/
            sqlFile = pkgs.writeText "dawarich-postgres-setup.sql" ''
              CREATE EXTENSION IF NOT EXISTS postgis;
              SELECT postgis_extensions_upgrade();
            '';
          in
          lib.mkIf cfg.database.createLocally [
            ''
              ${lib.getExe' config.services.postgresql.package "psql"} -d "${cfg.database.name}" -f "${sqlFile}"
            ''
          ];

        systemd.targets.dawarich = {
          after = [ "network.target" ];
          description = "Target for all Dawarich services";
          wantedBy = [ "multi-user.target" ];
        };

        systemd.tmpfiles.settings."dawarich"."${dataDir}/imports/watched".d = {
          group = "dawarich";
          mode = "700";
          user = "dawarich";
        };

        users.groups = lib.mkIf (cfg.group == "dawarich") { ${cfg.group} = { }; };

        users.users = lib.mkIf (cfg.user == "dawarich") {
          dawarich = {
            inherit (cfg) group;
            home = cfg.package;
            isSystemUser = true;
          };
        };
      }
      {
        systemd.services = lib.mkMerge [
          sidekiqUnits
        ];
      }
    ]
  );

  meta.maintainers = with lib.maintainers; [
    diogotcorreia
    tmarkus
  ];

}
