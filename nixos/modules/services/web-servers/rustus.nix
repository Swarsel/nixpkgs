{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.rustus;
in
{
  options.services.rustus = {

    enable = mkEnableOption "TUS protocol implementation in Rust";

    cors = mkOption {
      default = [ "*" ];

      description = ''
        list of origins allowed to upload
      '';

      example = [
        "*.staging.domain"
        "*.prod.domain"
      ];

      type = types.listOf types.str;
    };

    disable_health_access_logs = mkOption {
      default = false;

      description = ''
        disable access log for /health endpoint
      '';

      type = types.bool;
    };

    host = mkOption {
      default = "127.0.0.1";

      description = ''
        The host that rustus will connect to.
      '';

      example = "127.0.0.1";
      type = types.str;
    };

    info_storage = lib.mkOption {
      default = { };

      description = ''
        Info storages are used to store information about file uploads. These storages must be persistent, because every time chunk is uploaded rustus updates information about upload. And when someone wants to download file, information about it requested from storage to get actual path of an upload.
      '';

      type = lib.types.submodule {
        options = {
          dir = lib.mkOption {
            default = "/var/lib/rustus";
            description = "directory to store info about uploads";
            type = lib.types.str;
          };

          type = lib.mkOption {
            default = "file-info-storage";
            description = "Type of info storage to use";
            type = lib.types.enum [ "file-info-storage" ];
          };
        };
      };
    };

    log_level = mkOption {
      default = "INFO";

      description = ''
        Desired log level
      '';

      example = "ERROR";

      type = types.enum [
        "DEBUG"
        "INFO"
        "ERROR"
      ];
    };

    max_body_size = mkOption {
      default = "10000000"; # 10 mb

      description = ''
        Maximum body size in bytes
      '';

      example = "100000000";
      type = types.str;
    };

    port = mkOption {
      default = 1081;

      description = ''
        The port that rustus will connect to.
      '';

      example = 1081;
      type = types.port;
    };

    remove_parts = mkOption {
      default = true;

      description = ''
        remove parts files after successful concatenation
      '';

      example = false;
      type = types.bool;
    };

    storage = lib.mkOption {
      default = { };

      description = ''
        Storages are used to actually store your files. You can configure where you want to store files.
      '';

      example = lib.literalExpression ''
        {
          type = "hybrid-s3"
          s3_access_key_file = konfig.age.secrets.R2_ACCESS_KEY.path;
          s3_secret_key_file = konfig.age.secrets.R2_SECRET_KEY.path;
          s3_bucket = "my_bucket";
          s3_url = "https://s3.example.com";
        }
      '';

      type = lib.types.submodule {
        options = {
          data_dir = lib.mkOption {
            default = "/var/lib/rustus";
            description = "path to the local directory where all files are stored";
            type = lib.types.str;
          };

          dir_structure = lib.mkOption {
            default = "{year}/{month}/{day}";
            description = "pattern of a directory structure locally and on s3";
            type = lib.types.str;
          };

          force_sync = lib.mkOption {
            default = true;
            description = "calls fsync system call after every write to disk in local storage";
            type = lib.types.bool;
          };

          s3_access_key_file = lib.mkOption {
            description = "File path that contains the S3 access key.";
            type = lib.types.str;
          };

          s3_bucket = lib.mkOption {
            description = "S3 bucket.";
            type = lib.types.str;
          };

          s3_region = lib.mkOption {
            default = "us-east-1";
            description = "S3 region name.";
            type = lib.types.str;
          };

          s3_secret_key_file = lib.mkOption {
            description = "File path that contains the S3 secret key.";
            type = lib.types.path;
          };

          s3_url = lib.mkOption {
            description = "S3 url.";
            type = lib.types.str;
          };

          type = lib.mkOption {
            description = "Type of storage to use";

            type = lib.types.enum [
              "file-storage"
              "hybrid-s3"
            ];
          };
        };
      };
    };

    tus_extensions = mkOption {
      default = [
        "getting"
        "creation"
        "termination"
        "creation-with-upload"
        "creation-defer-length"
        "concatenation"
        "checksum"
      ];

      description = ''
        Since TUS protocol offers extensibility you can turn off some protocol extensions.
      '';

      type = types.listOf (
        types.enum [
          "getting"
          "creation"
          "termination"
          "creation-with-upload"
          "creation-defer-length"
          "concatenation"
          "checksum"
        ]
      );
    };

    url = mkOption {
      default = "/files";

      description = ''
        url path for uploads
      '';

      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services.rustus =
      let
        isHybridS3 = cfg.storage.type == "hybrid-s3";
      in
      {
        after = [ "network.target" ];
        description = "Rustus server";
        documentation = [ "https://s3rius.github.io/rustus/" ];

        environment = {
          RUSTUS_CORS = lib.concatStringsSep "," cfg.cors;
          RUSTUS_DATA_DIR = cfg.storage.data_dir;
          RUSTUS_DIR_STRUCTURE = cfg.storage.dir_structure;
          RUSTUS_DISABLE_HEALTH_ACCESS_LOG = lib.mkIf cfg.disable_health_access_logs "true";
          RUSTUS_FORCE_FSYNC = if cfg.storage.force_sync then "true" else "false";
          RUSTUS_INFO_DIR = cfg.info_storage.dir;
          RUSTUS_INFO_STORAGE = cfg.info_storage.type;
          RUSTUS_LOG_LEVEL = cfg.log_level;
          RUSTUS_MAX_BODY_SIZE = cfg.max_body_size;
          RUSTUS_REMOVE_PARTS = if cfg.remove_parts then "true" else "false";
          RUSTUS_S3_ACCESS_KEY_PATH = mkIf isHybridS3 "%d/S3_ACCESS_KEY_PATH";
          RUSTUS_S3_BUCKET = mkIf isHybridS3 cfg.storage.s3_bucket;
          RUSTUS_S3_REGION = mkIf isHybridS3 cfg.storage.s3_region;
          RUSTUS_S3_SECRET_KEY_PATH = mkIf isHybridS3 "%d/S3_SECRET_KEY_PATH";
          RUSTUS_S3_URL = mkIf isHybridS3 cfg.storage.s3_url;
          RUSTUS_SERVER_HOST = cfg.host;
          RUSTUS_SERVER_PORT = toString cfg.port;
          RUSTUS_STORAGE = cfg.storage.type;
          RUSTUS_TUS_EXTENSIONS = lib.concatStringsSep "," cfg.tus_extensions;
          RUSTUS_URL = cfg.url;
        };

        serviceConfig = {
          CapabilityBoundingSet = "";
          DynamicUser = true;
          ExecStart = "${pkgs.rustus}/bin/rustus";

          LoadCredential = lib.optionals isHybridS3 [
            "S3_ACCESS_KEY_PATH:${cfg.storage.s3_access_key_file}"
            "S3_SECRET_KEY_PATH:${cfg.storage.s3_secret_key_file}"
          ];

          LockPersonality = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHostUserNamespaces = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          RestrictNamespaces = true;
          # hardening
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          StateDirectory = "rustus";
          SystemCallArchitectures = "native";
          # User name is defined here to enable restoring a backup for example
          # You will run the backup restore command as sudo -u rustus in order
          # to have write permissions to /var/lib
          User = "rustus";
          # TODO consider SystemCallFilter LimitAS ProcSubset
        };

        wantedBy = [ "multi-user.target" ];
      };
  };

  meta.maintainers = with maintainers; [ happysalada ];
}
