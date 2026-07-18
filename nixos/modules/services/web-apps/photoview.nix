{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.photoview;

  dbUrl = {
    mysql = "PHOTOVIEW_MYSQL_URL=${cfg.database.user}:$(cat $CREDENTIALS_DIRECTORY/db_password)@tcp(${cfg.database.host}:${toString cfg.database.port})/${cfg.database.name}";
    postgres = "PHOTOVIEW_POSTGRES_URL=postgres://${cfg.database.user}:$(cat $CREDENTIALS_DIRECTORY/db_password)@${cfg.database.host}:${toString cfg.database.port}/${cfg.database.name}";
    sqlite = "PHOTOVIEW_SQLITE_PATH=${cfg.dataDir}/photoview.db";
  };
in

{
  options.services.photoview = {
    enable = lib.mkEnableOption "Photoview, a photo gallery for self-hosted personal servers";
    package = lib.mkPackageOption pkgs "photoview" { };

    dataDir = lib.mkOption {
      default = "/var/lib/photoview";
      description = "Directory for photoview state, cache, and database.";
      type = lib.types.path;
    };

    database = {
      host = lib.mkOption {
        default = "localhost";
        description = "Database host address.";
        type = lib.types.str;
      };

      name = lib.mkOption {
        default = "photoview";
        description = "Database name.";
        type = lib.types.str;
      };

      passwordFile = lib.mkOption {
        default = null;

        description = ''
          Path to a file containing the database password.
          Required when using MySQL or PostgreSQL.
        '';

        type = lib.types.nullOr lib.types.path;
      };

      port = lib.mkOption {
        default = 5432;
        description = "Database port.";
        type = lib.types.port;
      };

      type = lib.mkOption {
        default = "sqlite";
        description = "Database engine to use.";

        type = lib.types.enum [
          "sqlite"
          "mysql"
          "postgres"
        ];
      };

      user = lib.mkOption {
        default = "photoview";
        description = "Database user.";
        type = lib.types.str;
      };
    };

    group = lib.mkOption {
      default = "photoview";
      description = "Group under which photoview runs.";
      type = lib.types.str;
    };

    host = lib.mkOption {
      default = "127.0.0.1";
      description = "Address to listen on.";
      type = lib.types.str;
    };

    mediaPath = lib.mkOption {
      description = ''
        Path to the directory containing photos to be served.
        This directory must be readable by the photoview user.
      '';

      example = "/mnt/photos";
      type = lib.types.path;
    };

    port = lib.mkOption {
      default = 4001;
      description = "Port to listen on.";
      type = lib.types.port;
    };

    secretsFile = lib.mkOption {
      default = null;

      description = ''
        Path to an environment file containing secrets.
        Can be used for MAPBOX_TOKEN or other sensitive settings.
      '';

      type = lib.types.nullOr lib.types.path;
    };

    settings = {
      disableFaceRecognition = lib.mkOption {
        default = false;
        description = "Disable face recognition feature.";
        type = lib.types.bool;
      };

      disableRawProcessing = lib.mkOption {
        default = false;
        description = "Disable RAW photo processing.";
        type = lib.types.bool;
      };

      disableVideoEncoding = lib.mkOption {
        default = false;
        description = "Disable video encoding with FFmpeg.";
        type = lib.types.bool;
      };

      mapboxToken = lib.mkOption {
        default = null;
        description = "Mapbox API token for map features.";
        type = lib.types.nullOr lib.types.str;
      };

      videoEncoder = lib.mkOption {
        default = null;
        description = "Hardware video encoder to use.";

        type = lib.types.nullOr (
          lib.types.enum [
            "h264_qsv"
            "h264_vaapi"
            "h264_nvenc"
          ]
        );
      };
    };

    user = lib.mkOption {
      default = "photoview";
      description = "User account under which photoview runs.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.database.type == "sqlite" || cfg.database.passwordFile != null;
        message = "services.photoview.database.passwordFile must be set when using MySQL or PostgreSQL.";
      }
    ];

    systemd.services.photoview = {
      after = [
        "network.target"
      ]
      ++ lib.optional (cfg.database.type == "postgres") "postgresql.service"
      ++ lib.optional (cfg.database.type == "mysql") "mysql.service";

      description = "Photoview - Photo gallery for self-hosted personal servers";
      documentation = [ "https://photoview.github.io/docs/" ];

      environment = {
        PHOTOVIEW_DATABASE_DRIVER = cfg.database.type;
        PHOTOVIEW_DISABLE_FACE_RECOGNITION = toString cfg.settings.disableFaceRecognition;
        PHOTOVIEW_DISABLE_RAW_PROCESSING = toString cfg.settings.disableRawProcessing;
        PHOTOVIEW_DISABLE_VIDEO_ENCODING = toString cfg.settings.disableVideoEncoding;
        PHOTOVIEW_LISTEN_IP = cfg.host;
        PHOTOVIEW_LISTEN_PORT = toString cfg.port;
        PHOTOVIEW_MEDIA_CACHE = "/var/cache/photoview";
      }
      // lib.optionalAttrs (cfg.settings.mapboxToken != null) {
        MAPBOX_TOKEN = cfg.settings.mapboxToken;
      }
      // lib.optionalAttrs (cfg.settings.videoEncoder != null) {
        PHOTOVIEW_VIDEO_ENCODER = cfg.settings.videoEncoder;
      };

      requires =
        lib.optional (cfg.database.type == "postgres") "postgresql.service"
        ++ lib.optional (cfg.database.type == "mysql") "mysql.service";

      script = ''
        export ${dbUrl.${cfg.database.type}}
        exec ${lib.getExe cfg.package}
      '';

      serviceConfig = {
        CacheDirectory = "photoview";
        CacheDirectoryMode = "0750";
        # Hardening
        CapabilityBoundingSet = "";
        EnvironmentFile = lib.optional (cfg.secretsFile != null) cfg.secretsFile;
        Group = cfg.group;

        # Secrets
        LoadCredential = lib.optional (
          cfg.database.passwordFile != null
        ) "db_password:${cfg.database.passwordFile}";

        LockPersonality = true;
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
        ProtectSystem = "strict";
        # Read access to media directory
        ReadOnlyPaths = [ cfg.mediaPath ];
        Restart = "on-failure";
        RestartSec = 5;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "photoview";
        StateDirectoryMode = "0750";
        SystemCallArchitectures = "native";
        UMask = "0077";
        User = cfg.user;
        WorkingDirectory = cfg.dataDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.mkIf (cfg.group == "photoview") {
      photoview = { };
    };

    users.users = lib.mkIf (cfg.user == "photoview") {
      photoview = {
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ nettika ];
}
