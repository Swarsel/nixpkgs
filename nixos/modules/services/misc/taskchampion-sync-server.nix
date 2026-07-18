{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  cfg = config.services.taskchampion-sync-server;
  defaultUser = "taskchampion";
  defaultGroup = "taskchampion";
  defaultDir = "/var/lib/taskchampion-sync-server";
in
{
  options.services.taskchampion-sync-server = {
    enable = lib.mkEnableOption "TaskChampion Sync Server for Taskwarrior 3";
    package = lib.mkPackageOption pkgs "taskchampion-sync-server" { };

    allowClientIds = lib.mkOption {
      default = [ ];
      description = "Client IDs to allow (can be repeated; if not specified, all clients are allowed)";
      type = types.listOf types.str;
    };

    dataDir = lib.mkOption {
      default = defaultDir;
      description = "Directory in which to store data";
      type = types.path;
    };

    dynamicUser = lib.mkOption {
      default = lib.versionAtLeast config.system.stateVersion "26.05";
      description = "Whether to use dynamic user";
      type = types.bool;
    };

    group = lib.mkOption {
      default = defaultGroup;
      description = "Unix Group to run the server under";
      type = types.str;
    };

    host = lib.mkOption {
      default = "127.0.0.1";
      description = "Host address on which to serve";
      example = "0.0.0.0";
      type = types.str;
    };

    openFirewall = lib.mkEnableOption "Open firewall port for taskchampion-sync-server";

    port = lib.mkOption {
      default = 10222;
      description = "Port on which to serve";
      type = types.port;
    };

    snapshot = {
      days = lib.mkOption {
        default = 14;
        description = "Target number of days between snapshots";
        type = types.ints.positive;
      };

      versions = lib.mkOption {
        default = 100;
        description = "Target number of versions between snapshots";
        type = types.ints.positive;
      };
    };

    user = lib.mkOption {
      default = defaultUser;
      description = "Unix User to run the server under";
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf (cfg.openFirewall) [ cfg.port ];

    systemd.services.taskchampion-sync-server = {
      after = [ "network.target" ];

      serviceConfig = {
        DynamicUser = cfg.dynamicUser;

        ExecStart = ''
          ${lib.getExe cfg.package} \
            --listen "${cfg.host}:${toString cfg.port}" \
            --data-dir ${cfg.dataDir} \
            --snapshot-versions ${toString cfg.snapshot.versions} \
            --snapshot-days ${toString cfg.snapshot.days} \
            ${lib.concatMapStringsSep " " (id: "--allow-client-id ${id}") cfg.allowClientIds}
        '';

        Group = cfg.group;
        StateDirectory = lib.mkIf (cfg.dataDir == defaultDir) "taskchampion-sync-server";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.${cfg.group} = lib.mkIf (!cfg.dynamicUser && cfg.group == defaultGroup) { };

    users.users.${cfg.user} = lib.mkIf (!cfg.dynamicUser && cfg.user == defaultUser) {
      inherit (cfg) group;
      isSystemUser = true;
    };
  };
}
