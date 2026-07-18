{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.jackett;

in
{
  options = {
    services.jackett = {
      enable = lib.mkEnableOption "Jackett, API support for your favorite torrent trackers";
      package = lib.mkPackageOption pkgs "jackett" { };

      dataDir = lib.mkOption {
        default = "/var/lib/jackett/.config/Jackett";
        description = "The directory where Jackett stores its data files.";
        type = lib.types.str;
      };

      group = lib.mkOption {
        default = "jackett";
        description = "Group under which Jackett runs.";
        type = lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = false;
        description = "Open ports in the firewall for the Jackett web interface.";
        type = lib.types.bool;
      };

      port = lib.mkOption {
        default = 9117;

        description = ''
          Port serving the web interface
        '';

        type = lib.types.port;
      };

      user = lib.mkOption {
        default = "jackett";
        description = "User account under which Jackett runs.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.jackett = {
      after = [ "network.target" ];
      description = "Jackett";

      serviceConfig = {
        # Sandboxing
        CapabilityBoundingSet = [
          "CAP_NET_BIND_SERVICE"
        ];

        ExecPaths = [
          "${builtins.storeDir}"
        ];

        ExecStart = "${cfg.package}/bin/Jackett --NoUpdates --Port ${toString cfg.port} --DataFolder '${cfg.dataDir}'";
        Group = cfg.group;
        LockPersonality = true;

        NoExecPaths = [
          "/"
        ];

        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";

        ReadWritePaths = [
          cfg.dataDir
        ];

        RemoveIPC = true;
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@clock"
          "~@cpu-emulation"
          "~@debug"
          "~@obsolete"
          "~@reboot"
          "~@module"
          "~@mount"
          "~@swap"
        ];

        Type = "simple";
        UMask = "0077";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -"
    ];

    users.groups = lib.mkIf (cfg.group == "jackett") {
      jackett.gid = config.ids.gids.jackett;
    };

    users.users = lib.mkIf (cfg.user == "jackett") {
      jackett = {
        group = cfg.group;
        home = cfg.dataDir;
        uid = config.ids.uids.jackett;
      };
    };
  };
}
