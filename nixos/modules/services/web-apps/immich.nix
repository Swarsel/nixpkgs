{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.immich;
  format = pkgs.formats.json { };
  isPostgresUnixSocket = lib.hasPrefix "/" cfg.database.host;
  isRedisUnixSocket = lib.hasPrefix "/" cfg.redis.host;
  secretsReplacement = utils.genJqSecretsReplacement {
    loadCredential = true;
  } cfg.settings "/run/immich/config.json";

  commonServiceConfig = {
    # Hardening
    CapabilityBoundingSet = "";
    DeviceAllow = mkIf (cfg.accelerationDevices != null) cfg.accelerationDevices;
    NoNewPrivileges = true;
    PrivateDevices = cfg.accelerationDevices == [ ];
    PrivateMounts = true;
    PrivateTmp = true;
    PrivateUsers = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
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
    Type = "simple";
    UMask = "0077";
  };
  inherit (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    ;

  postgresqlPackage =
    if cfg.database.enable then config.services.postgresql.package else pkgs.postgresql;
in
{
  imports = [
    (lib.mkRemovedOptionModule
      [
        "services"
        "immich"
        "secretSettings"
      ]
      ''
        `secretSettings` has been deprecated as secrets can now be specified
        directly in `settings`. To do so, set `_secret` of the desired
        attribute to a file path, for example:
          `services.immich.settings.oauth.clientSecret._secret = "/path/to/secret/file";`
      ''
    )
    (lib.mkRemovedOptionModule
      [
        "services"
        "immich"
        "database"
        "enableVectorChord"
      ]
      ''
        `database.enableVectorChord` has been deprecated as the pgvecto.rs alternative
        is no longer available. From now on, vectorchord is always enabled.
      ''
    )
    (lib.mkRemovedOptionModule
      [
        "services"
        "immich"
        "database"
        "enableVectors"
      ]
      ''
        `database.enableVectors` has been deprecated as pgvecto.rs is no longer available.
        From now on, vectorchord is used instead.
      ''
    )
  ];

  options.services.immich = {
    enable = mkEnableOption "Immich";
    package = lib.mkPackageOption pkgs "immich" { };

    accelerationDevices = mkOption {
      default = [ ];

      description = ''
        A list of device paths to hardware acceleration devices that immich should
        have access to. This is useful when transcoding media files.
        The special value `[ ]` will disallow all devices using `PrivateDevices`. `null` will give access to all devices.
      '';

      example = [ "/dev/dri/renderD128" ];
      type = types.nullOr (types.listOf types.str);
    };

    database = {
      enable =
        mkEnableOption "the postgresql database for use with immich. See {option}`services.postgresql`"
        // {
          default = true;
        };

      createDB = mkEnableOption "the automatic creation of the database for immich." // {
        default = true;
      };

      host = mkOption {
        default = "/run/postgresql";
        description = "Hostname or address of the postgresql server. If an absolute path is given here, it will be interpreted as a unix socket path.";
        example = "127.0.0.1";
        type = types.str;
      };

      name = mkOption {
        default = "immich";
        description = "The name of the immich database.";
        type = types.str;
      };

      port = mkOption {
        default = 5432;
        description = "Port of the postgresql server.";
        type = types.port;
      };

      user = mkOption {
        default = "immich";
        description = "The database user for immich.";
        type = types.str;
      };
    };

    environment = mkOption {
      default = { };

      description = ''
        Extra configuration environment variables. Refer to the [documentation](https://immich.app/docs/install/environment-variables) for options tagged with 'server', 'api' or 'microservices'.
      '';

      example = {
        IMMICH_LOG_LEVEL = "verbose";
      };

      type = types.submodule { freeformType = types.attrsOf types.str; };
    };

    group = mkOption {
      default = "immich";
      description = "The group immich should run as.";
      type = types.str;
    };

    host = mkOption {
      default = "localhost";
      description = "The host that immich will listen on.";
      type = types.str;
    };

    machine-learning = {
      enable =
        mkEnableOption "immich's machine-learning functionality to detect faces and search for objects"
        // {
          default = true;
        };

      environment = mkOption {
        default = { };

        description = ''
          Extra configuration environment variables. Refer to the [documentation](https://immich.app/docs/install/environment-variables) for options tagged with 'machine-learning'.
        '';

        example = {
          MACHINE_LEARNING_MODEL_TTL = "600";
        };

        type = types.submodule { freeformType = types.attrsOf types.str; };
      };
    };

    mediaLocation = mkOption {
      default = "/var/lib/immich";
      description = "Directory used to store media files. If it is not the default, the directory has to be created manually such that the immich user is able to read and write to it.";
      type = types.path;
    };

    openFirewall = mkOption {
      default = false;
      description = "Whether to open the immich port in the firewall";
      type = types.bool;
    };

    port = mkOption {
      default = 2283;
      description = "The port that immich will listen on.";
      type = types.port;
    };

    redis = {
      enable = mkEnableOption "a redis cache for use with immich" // {
        default = true;
      };

      host = mkOption {
        default = config.services.redis.servers.immich.unixSocket;
        defaultText = lib.literalExpression "config.services.redis.servers.immich.unixSocket";
        description = "The host that redis will listen on.";
        type = types.str;
      };

      port = mkOption {
        default = 0;
        description = "The port that redis will listen on. Set to zero to disable TCP.";
        type = types.port;
      };
    };

    secretsFile = mkOption {
      default = null;

      description = ''
        Path of a file with extra environment variables to be loaded from disk. This file is not added to the nix store, so it can be used to pass secrets to immich. Refer to the [documentation](https://immich.app/docs/install/environment-variables) for options.

        To set a database password set this to a file containing:
        ```
        DB_PASSWORD=<pass>
        ```
      '';

      example = "/run/secrets/immich";

      type = types.nullOr (
        types.str
        // {
          # We don't want users to be able to pass a path literal here but
          # it should look like a path.
          check = it: lib.isString it && lib.types.path.check it;
        }
      );
    };

    settings = mkOption {
      default = null;

      description = ''
        Configuration for Immich.
        See <https://immich.app/docs/install/config-file/> or navigate to
        <https://my.immich.app/admin/system-settings> for
        options and defaults.
        Setting it to `null` allows configuring Immich in the web interface.
        You can load secret values from a file in this configuration by setting `somevalue._secret = "/path/to/file"` instead of setting `somevalue` directly.
      '';

      type = types.nullOr (
        types.submodule {
          options = {
            newVersionCheck.enabled = mkOption {
              default = false;

              description = ''
                Check for new versions.
                This feature relies on periodic communication with github.com.
              '';

              type = types.bool;
            };

            server.externalDomain = mkOption {
              default = "";
              description = "Domain for publicly shared links, including `http(s)://`.";
              type = types.str;
            };
          };

          freeformType = format.type;
        }
      );
    };

    user = mkOption {
      default = "immich";
      description = "The user immich should run as.";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !isPostgresUnixSocket -> cfg.secretsFile != null;
        message = "A secrets file containing at least the database password must be provided when unix sockets are not used.";
      }
    ];

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    services.immich.environment =
      let
        postgresEnv =
          if isPostgresUnixSocket then
            { DB_URL = "postgresql:///${cfg.database.name}?host=${cfg.database.host}"; }
          else
            {
              DB_DATABASE_NAME = cfg.database.name;
              DB_HOSTNAME = cfg.database.host;
              DB_PORT = toString cfg.database.port;
              DB_USERNAME = cfg.database.user;
            };
        redisEnv =
          if isRedisUnixSocket then
            { REDIS_SOCKET = cfg.redis.host; }
          else
            {
              REDIS_HOSTNAME = cfg.redis.host;
              REDIS_PORT = toString cfg.redis.port;
            };
      in
      postgresEnv
      // redisEnv
      // {
        IMMICH_HOST = cfg.host;
        IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";
        IMMICH_MEDIA_LOCATION = cfg.mediaLocation;
        IMMICH_PORT = toString cfg.port;
      }
      // lib.optionalAttrs (cfg.settings != null) {
        IMMICH_CONFIG_FILE = "/run/immich/config.json";
      };

    services.immich.machine-learning.environment = {
      IMMICH_HOST = "localhost";
      IMMICH_PORT = "3003";
      MACHINE_LEARNING_CACHE_FOLDER = "/var/cache/immich";
      MACHINE_LEARNING_WORKERS = "1";
      MACHINE_LEARNING_WORKER_TIMEOUT = "120";
      XDG_CACHE_HOME = "/var/cache/immich";
    };

    services.postgresql = mkIf cfg.database.enable {
      enable = true;
      ensureDatabases = mkIf cfg.database.createDB [ cfg.database.name ];

      ensureUsers = mkIf cfg.database.createDB [
        {
          ensureClauses.login = true;
          ensureDBOwnership = true;
          name = cfg.database.user;
        }
      ];

      extensions = ps: [
        ps.pgvector
        ps.vectorchord
      ];

      settings = {
        search_path = "\"$user\", public, vectors";
        shared_preload_libraries = [ "vchord.so" ];
      };
    };

    services.redis.servers = mkIf cfg.redis.enable {
      immich = {
        enable = true;
        bind = mkIf (!isRedisUnixSocket) cfg.redis.host;
        port = cfg.redis.port;
      };
    };

    systemd.services.immich-machine-learning = mkIf cfg.machine-learning.enable {
      inherit (cfg.machine-learning) environment;
      after = [ "network.target" ] ++ lib.optionals cfg.database.enable [ "postgresql.target" ];
      description = "immich machine learning";
      requires = lib.mkIf cfg.database.enable [ "postgresql.target" ];

      serviceConfig = commonServiceConfig // {
        CacheDirectory = "immich";
        ExecStart = lib.getExe cfg.package.machine-learning;
        Group = cfg.group;
        Slice = "system-immich.slice";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.immich-server = {
      inherit (cfg) environment;
      after = [ "network.target" ] ++ lib.optionals cfg.database.enable [ "postgresql.target" ];
      description = "Immich backend server (Self-hosted photo and video backup solution)";

      path = [
        # gzip and pg_dumpall are used by the backup service
        pkgs.gzip
        postgresqlPackage
      ];

      preStart = mkIf (cfg.settings != null) secretsReplacement.script;
      requires = lib.mkIf cfg.database.enable [ "postgresql.target" ];

      serviceConfig = commonServiceConfig // {
        EnvironmentFile = mkIf (cfg.secretsFile != null) cfg.secretsFile;
        ExecStart = lib.getExe cfg.package;
        Group = cfg.group;
        LoadCredential = secretsReplacement.credentials;
        RuntimeDirectory = "immich";
        Slice = "system-immich.slice";
        StateDirectory = "immich";

        # ensure that immich-server has permission to connect to the redis socket.
        SupplementaryGroups = mkIf (cfg.redis.enable && isRedisUnixSocket) [
          config.services.redis.servers.immich.group
        ];

        SyslogIdentifier = "immich";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.postgresql-setup.serviceConfig.ExecStartPost =
      let
        extensions = [
          "unaccent"
          "uuid-ossp"
          "cube"
          "earthdistance"
          "pg_trgm"
          "vector"
          "vchord"
        ];
        sqlFile = pkgs.writeText "immich-pgvectors-setup.sql" ''
          -- save previous version of vectorchord to trigger reindex on update
          SELECT COALESCE(installed_version, ''') AS vchord_version_before FROM pg_available_extensions WHERE name = 'vchord' \gset

          ${lib.concatMapStringsSep "\n" (ext: "CREATE EXTENSION IF NOT EXISTS \"${ext}\";") extensions}
          ${lib.concatMapStringsSep "\n" (ext: "ALTER EXTENSION \"${ext}\" UPDATE;") extensions}
          ALTER SCHEMA public OWNER TO ${cfg.database.user};

          -- trigger reindex if vectorchord updates
          -- https://docs.immich.app/administration/postgres-standalone/#updating-vectorchord
          SELECT COALESCE(installed_version, ''') AS vchord_version_after FROM pg_available_extensions WHERE name = 'vchord' \gset

          SELECT (:'vchord_version_before' != ''' AND :'vchord_version_before' != :'vchord_version_after') AS has_vchord_updated \gset
          \if :has_vchord_updated
            REINDEX INDEX face_index;
            REINDEX INDEX clip_index;
          \endif
        '';
      in
      [
        ''
          ${lib.getExe' postgresqlPackage "psql"} -d "${cfg.database.name}" -f "${sqlFile}"
        ''
      ];

    systemd.slices.system-immich = {
      description = "Immich (self-hosted photo and video backup solution) slice";
      documentation = [ "https://immich.app/docs" ];
    };

    systemd.tmpfiles.settings = {
      immich = {
        # Redundant to the `UMask` service config setting on new installs, but installs made in
        # early 24.11 created world-readable media storage by default, which is a privacy risk. This
        # fixes those installs.
        "${cfg.mediaLocation}" = {
          e = {
            group = cfg.group;
            mode = "0700";
            user = cfg.user;
          };
        };
      };
    };

    users.groups = mkIf (cfg.group == "immich") { immich = { }; };

    users.users = mkIf (cfg.user == "immich") {
      immich = {
        group = cfg.group;
        isSystemUser = true;
        name = "immich";
      };
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ jvanbruegge ];
  };
}
