{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.nostr-rs-relay;
  settingsFormat = pkgs.formats.toml { };
  configFile = settingsFormat.generate "config.toml" (
    cfg.settings
    // {
      database = {
        data_directory = config.services.nostr-rs-relay.dataDir;
      };

      network = {
        port = config.services.nostr-rs-relay.port;
      };
    }
  );
in
{
  options.services.nostr-rs-relay = {
    enable = lib.mkEnableOption "nostr-rs-relay";
    package = lib.mkPackageOption pkgs "nostr-rs-relay" { };

    dataDir = lib.mkOption {
      default = "/var/lib/nostr-rs-relay";
      description = "Directory for SQLite files.";
      type = lib.types.path;
    };

    port = lib.mkOption {
      default = 12849;
      description = "Listen on this port.";
      type = lib.types.port;
    };

    settings = lib.mkOption {
      inherit (settingsFormat) type;
      default = { };
      description = "See <https://git.sr.ht/~gheartsfield/nostr-rs-relay/#configuration> for documentation.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.nostr-rs-relay = {
      description = "nostr-rs-relay";

      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/nostr-rs-relay --config ${configFile}";
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
        ReadWritePaths = [ cfg.dataDir ];
        RemoveIPC = true;
        Restart = "on-failure";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "nostr-rs-relay";
        StateDirectory = "nostr-rs-relay";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
        ];

        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    felixzieger
    jb55
  ];
}
