{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.surrealdb;
in
{

  options = {
    services.surrealdb = {
      enable = lib.mkEnableOption "SurrealDB, a scalable, distributed, collaborative, document-graph database, for the realtime web";
      package = lib.mkPackageOption pkgs "surrealdb" { };

      dbPath = lib.mkOption {
        default = "rocksdb:///var/lib/surrealdb/";

        description = ''
          The path that surrealdb will write data to. Use null for in-memory.
          Can be one of "memory", "rocksdb://:path", "surrealkv://:path", "tikv://:addr", "fdb://:addr".
        '';

        example = "memory";
        type = lib.types.str;
      };

      extraFlags = lib.mkOption {
        default = [ ];

        description = ''
          Specify a list of additional command line flags.
        '';

        example = [
          "--allow-all"
          "--user"
          "root"
          "--pass"
          "root"
        ];

        type = lib.types.listOf lib.types.str;
      };

      host = lib.mkOption {
        default = "127.0.0.1";

        description = ''
          The host that surrealdb will connect to.
        '';

        example = "127.0.0.1";
        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 8000;

        description = ''
          The port that surrealdb will connect to.
        '';

        example = 8000;
        type = lib.types.port;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    # Used to connect to the running service
    environment.systemPackages = [ cfg.package ];

    systemd.services.surrealdb = {
      after = [ "network.target" ];
      description = "A scalable, distributed, collaborative, document-graph database, for the realtime web";

      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/surreal start --bind ${cfg.host}:${toString cfg.port} ${lib.strings.concatStringsSep " " cfg.extraFlags} -- ${cfg.dbPath}";
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
        StateDirectory = "surrealdb";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
