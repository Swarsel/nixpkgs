{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.restic.server;
in
{
  options.services.restic.server = {
    enable = lib.mkEnableOption "Restic REST Server";
    package = lib.mkPackageOption pkgs "restic-rest-server" { };

    appendOnly = lib.mkOption {
      default = false;

      description = ''
        Enable append only mode.
        This mode allows creation of new backups but prevents deletion and modification of existing backups.
        This can be useful when backing up systems that have a potential of being hacked.
      '';

      type = lib.types.bool;
    };

    dataDir = lib.mkOption {
      default = "/var/lib/restic";
      description = "The directory for storing the restic repository.";
      type = lib.types.path;
    };

    extraFlags = lib.mkOption {
      default = [ ];

      description = ''
        Extra commandline options to pass to Restic REST server.
      '';

      type = lib.types.listOf lib.types.str;
    };

    htpasswd-file = lib.mkOption {
      default = null;
      description = "The path to the servers .htpasswd file. Defaults to `\${dataDir}/.htpasswd`.";
      type = lib.types.nullOr lib.types.path;
    };

    listenAddress = lib.mkOption {
      default = "8000";
      description = "Listen on a specific IP address and port or unix socket.";
      example = "127.0.0.1:8080";
      type = lib.types.str;
    };

    privateRepos = lib.mkOption {
      default = false;

      description = ''
        Enable private repos.
        Grants access only when a subdirectory with the same name as the user is specified in the repository URL.
      '';

      type = lib.types.bool;
    };

    prometheus = lib.mkOption {
      default = false;
      description = "Enable Prometheus metrics at /metrics.";
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.substring 0 1 cfg.listenAddress != ":";

        message = "The restic-rest-server now uses systemd socket activation, which expects only the Port number: services.restic.server.listenAddress = \"${
          lib.substring 1 6 cfg.listenAddress
        }\";";
      }
    ];

    systemd.services.restic-rest-server = {
      after = [
        "network.target"
        "restic-rest-server.socket"
      ];

      description = "Restic REST Server";
      requires = [ "restic-rest-server.socket" ];

      serviceConfig = {
        # Security hardening
        CapabilityBoundingSet = "";

        ExecStart = ''
          ${cfg.package}/bin/rest-server \
          --path ${cfg.dataDir} \
          ${lib.optionalString (cfg.htpasswd-file != null) "--htpasswd-file ${cfg.htpasswd-file}"} \
          ${lib.optionalString cfg.appendOnly "--append-only"} \
          ${lib.optionalString cfg.privateRepos "--private-repos"} \
          ${lib.optionalString cfg.prometheus "--prometheus"} \
          ${lib.escapeShellArgs cfg.extraFlags}
        '';

        Group = "restic";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateNetwork = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        ReadOnlyPaths = lib.optional (cfg.htpasswd-file != null) cfg.htpasswd-file;
        ReadWritePaths = [ cfg.dataDir ];
        RemoveIPC = true;
        RestrictAddressFamilies = "none";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
        Type = "simple";
        UMask = 27;
        User = "restic";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.sockets.restic-rest-server = {
      listenStreams = [ cfg.listenAddress ];

      socketConfig = {
        FreeBind = true;
        ReusePort = true;
      };

      wantedBy = [ "sockets.target" ];
    };

    systemd.tmpfiles.rules = lib.mkIf cfg.privateRepos [
      "f ${cfg.dataDir}/.htpasswd 0700 restic restic -"
    ];

    users.groups.restic.gid = config.ids.uids.restic;

    users.users.restic = {
      createHome = true;
      group = "restic";
      home = cfg.dataDir;
      uid = config.ids.uids.restic;
    };
  };

  meta.maintainers = [ lib.maintainers.bachp ];
}
