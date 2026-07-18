{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.qdrant;

  settingsFormat = pkgs.formats.yaml { };
  configFile = settingsFormat.generate "config.yaml" cfg.settings;
in
{

  options = {
    services.qdrant = {
      enable = lib.mkEnableOption "Vector Search Engine for the next generation of AI applications";
      package = lib.mkPackageOption pkgs "qdrant" { };

      settings = lib.mkOption {
        defaultText = lib.literalExpression ''
          {
            storage = {
              storage_path = "/var/lib/qdrant/storage";
              snapshots_path = "/var/lib/qdrant/snapshots";
            };
            hsnw_index = {
              on_disk = true;
            };
            service = {
              host = "127.0.0.1";
              http_port = 6333;
              grpc_port = 6334;
            };
            telemetry_disabled = true;
          }
        '';

        description = ''
          Configuration for Qdrant
          Refer to <https://github.com/qdrant/qdrant/blob/master/config/config.yaml> for details on supported values.
        '';

        example = {
          hsnw_index = {
            on_disk = true;
          };

          service = {
            grpc_port = 6334;
            host = "127.0.0.1";
            http_port = 6333;
          };

          storage = {
            snapshots_path = "/var/lib/qdrant/snapshots";
            storage_path = "/var/lib/qdrant/storage";
          };

          telemetry_disabled = true;
        };

        type = settingsFormat.type;
      };

      webUIPackage = lib.mkPackageOption pkgs "qdrant-web-ui" { };
    };
  };

  config = lib.mkIf cfg.enable {
    services.qdrant.settings = {
      cluster.enabled = lib.mkDefault false;
      service.enable_cors = lib.mkDefault true;
      service.grpc_port = lib.mkDefault 6334;
      # the following have been altered for security
      service.host = lib.mkDefault "127.0.0.1";
      service.http_port = lib.mkDefault 6333;
      service.max_request_size_mb = lib.mkDefault 32;
      service.max_workers = lib.mkDefault 0;
      service.static_content_dir = lib.mkDefault cfg.webUIPackage;
      storage.hnsw_index.ef_construct = lib.mkDefault 100;
      storage.hnsw_index.full_scan_threshold_kb = lib.mkDefault 10000;
      storage.hnsw_index.m = lib.mkDefault 16;
      storage.hnsw_index.max_indexing_threads = lib.mkDefault 0;
      storage.hnsw_index.on_disk = lib.mkDefault false;
      storage.hnsw_index.payload_m = lib.mkDefault null;
      # The following default values are the same as in the default config,
      # they are just written here for convenience.
      storage.on_disk_payload = lib.mkDefault true;
      storage.optimizers.default_segment_number = lib.mkDefault 0;
      storage.optimizers.deleted_threshold = lib.mkDefault 0.2;
      storage.optimizers.flush_interval_sec = lib.mkDefault 5;
      storage.optimizers.indexing_threshold_kb = lib.mkDefault 20000;
      storage.optimizers.max_optimization_threads = lib.mkDefault 1;
      storage.optimizers.max_segment_size_kb = lib.mkDefault null;
      storage.optimizers.memmap_threshold_kb = lib.mkDefault null;
      storage.optimizers.vacuum_min_vector_number = lib.mkDefault 1000;
      storage.performance.max_optimization_threads = lib.mkDefault 1;
      storage.performance.max_search_threads = lib.mkDefault 0;
      storage.snapshots_path = lib.mkDefault "/var/lib/qdrant/snapshots";
      storage.storage_path = lib.mkDefault "/var/lib/qdrant/storage";
      storage.wal.wal_capacity_mb = lib.mkDefault 32;
      storage.wal.wal_segments_ahead = lib.mkDefault 0;
      telemetry_disabled = lib.mkDefault true;
    };

    systemd.services.qdrant = {
      after = [ "network.target" ];
      description = "Vector Search Engine for the next generation of AI applications";

      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/qdrant --config-path ${configFile}";
        LimitNOFILE = 65536;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "noaccess";
        RemoveIPC = true;
        Restart = "on-failure";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "qdrant";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
