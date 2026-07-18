{
  config,
  lib,
  pkgs,
  ...
}:
let
  defaultSettings = {
    db = "/var/lib/strfry";

    dbParams = {
      mapsize = 10995116277760;
      maxreaders = 256;
      noReadAhead = false;
    };

    events = {
      ephemeralEventsLifetimeSeconds = 300;
      maxEventSize = 65536;
      maxNumTags = 2000;
      maxTagValSize = 1024;
      rejectEphemeralEventsOlderThanSeconds = 60;
      rejectEventsNewerThanSeconds = 900;
      rejectEventsOlderThanSeconds = 94608000;
    };

    relay = {
      autoPingSeconds = 55;
      bind = "127.0.0.1";

      compression = {
        enabled = true;
        slidingWindow = true;
      };

      enableTcpKeepalive = false;

      info = {
        contact = "";
        description = "This is a strfry instance.";
        icon = "";
        name = "strfry default";
        nips = "";
        pubkey = "";
      };

      logging = {
        dbScanPerf = false;
        dumpInAll = false;
        dumpInEvents = false;
        dumpInReqs = false;
        invalidEvents = true;
      };

      maxFilterLimit = 500;
      maxReqFilterSize = 200;
      maxSubsPerConnection = 20;
      maxWebsocketPayloadSize = 131072;

      negentropy = {
        enabled = true;
        maxSyncEvents = 1000000;
      };

      nofiles = 1000000;

      numThreads = {
        ingester = 3;
        negentropy = 2;
        reqMonitor = 3;
        reqWorker = 3;
      };

      port = 7777;
      queryTimesliceBudgetMicroseconds = 10000;
      realIpHeader = "";

      writePolicy = {
        plugin = "";
      };
    };
  };

  cfg = config.services.strfry;
  settingsFormat = pkgs.formats.json { };
  configFile = settingsFormat.generate "config.json" cfg.settings;
in
{
  options.services.strfry = {
    enable = lib.mkEnableOption "strfry";
    package = lib.mkPackageOption pkgs "strfry" { };

    settings = lib.mkOption {
      apply = lib.recursiveUpdate defaultSettings;
      default = defaultSettings;
      description = "Configuration options to set for the Strfry service. See <https://github.com/hoytech/strfry> for documentation.";

      example = lib.literalExpression ''
        dbParams = {
          maxreaders = 256;
          mapsize = 10995116277760;
          noReadAhead = false;
        };
      '';

      type = settingsFormat.type;
    };

  };

  config = lib.mkIf cfg.enable {
    systemd.services.strfry = {
      description = "strfry";

      serviceConfig = {
        CapabilityBoundingSet = "";
        ExecStart = "${lib.getExe cfg.package} --config=${configFile} relay";
        Group = "strfry";
        LimitNOFILE = cfg.settings.relay.nofiles;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
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
        ReadWritePaths = [ cfg.settings.db ];
        RemoveIPC = true;
        Restart = "on-failure";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "strfry";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
        ];

        User = "strfry";
        WorkingDirectory = cfg.settings.db;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
    };

    users.groups.strfry = { };

    users.users.strfry = {
      description = "Strfry daemon user";
      group = "strfry";
      isSystemUser = true;
    };
  };

  meta = {
    doc = ./strfry.md;

    maintainers = with lib.maintainers; [
      felixzieger
    ];
  };
}
