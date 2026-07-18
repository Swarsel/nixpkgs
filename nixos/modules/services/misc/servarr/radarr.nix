{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.radarr;
  servarr = import ./settings-options.nix { inherit lib pkgs; };
in
{
  options = {
    services.radarr = {
      enable = lib.mkEnableOption "Radarr, a UsetNet/BitTorrent movie downloader";
      package = lib.mkPackageOption pkgs "radarr" { };

      dataDir = lib.mkOption {
        default = "/var/lib/radarr/.config/Radarr";
        description = "The directory where Radarr stores its data files.";
        type = lib.types.str;
      };

      environmentFiles = servarr.mkServarrEnvironmentFiles "radarr";

      group = lib.mkOption {
        default = "radarr";
        description = "Group under which Radarr runs.";
        type = lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = false;
        description = "Open ports in the firewall for the Radarr web interface.";
        type = lib.types.bool;
      };

      settings = servarr.mkServarrSettingsOptions "radarr" 7878;

      user = lib.mkOption {
        default = "radarr";
        description = "User account under which Radarr runs.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.settings.server.port ];
    };

    systemd.services.radarr = {
      after = [ "network.target" ];
      description = "Radarr";
      environment = servarr.mkServarrSettingsEnvVars "RADARR" cfg.settings;

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = "";
        EnvironmentFile = cfg.environmentFiles;
        ExecStart = "${cfg.package}/bin/Radarr -nobrowser -data='${cfg.dataDir}'";
        Group = cfg.group;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
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
        RemoveIPC = true;
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@debug"
          "~@mount"
          "@chown"
        ];

        Type = "simple";
        UMask = "0022";
        User = cfg.user;
      };

      unitConfig.RequiresMountsFor = [ cfg.dataDir ];
      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings."10-radarr".${cfg.dataDir}.d = {
      inherit (cfg) user group;
      mode = "0700";
    };

    users.groups = lib.mkIf (cfg.group == "radarr") {
      radarr.gid = config.ids.gids.radarr;
    };

    users.users = lib.mkIf (cfg.user == "radarr") {
      radarr = {
        group = cfg.group;
        home = cfg.dataDir;
        uid = config.ids.uids.radarr;
      };
    };
  };
}
