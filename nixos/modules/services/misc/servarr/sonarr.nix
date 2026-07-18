{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.sonarr;
  servarr = import ./settings-options.nix { inherit lib pkgs; };
in
{
  options = {
    services.sonarr = {
      enable = lib.mkEnableOption "Sonarr";
      package = lib.mkPackageOption pkgs "sonarr" { };

      dataDir = lib.mkOption {
        default = "/var/lib/sonarr/.config/NzbDrone";

        description = ''
          The Sonarr home directory used to store all data. If left as the default value
          this directory will automatically be created before the Sonarr server starts, otherwise
          you are responsible for ensuring the directory exists with appropriate ownership
          and permissions.
        '';

        type = lib.types.str;
      };

      environmentFiles = servarr.mkServarrEnvironmentFiles "sonarr";

      group = lib.mkOption {
        default = "sonarr";

        description = ''
          Group account under which Sonarr runs.

          ::: {.note}
          If left as the default value this group will automatically be created
          on system activation, otherwise you are responsible for
          ensuring the group exists before the Sonarr service starts.
          :::
        '';

        type = lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Open ports in the firewall for the Sonarr web interface
        '';

        type = lib.types.bool;
      };

      settings = servarr.mkServarrSettingsOptions "sonarr" 8989;

      user = lib.mkOption {
        default = "sonarr";

        description = ''
          User account under which Sonarr runs.";

          ::: {.note}
          If left as the default value this user will automatically be created
          on system activation, otherwise you are responsible for
          ensuring the user exists before the Sonarr service starts.
          :::
        '';

        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.settings.server.port ];
    };

    systemd.services.sonarr = {
      after = [ "network.target" ];
      description = "Sonarr";
      environment = servarr.mkServarrSettingsEnvVars "SONARR" cfg.settings;

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = "";
        EnvironmentFile = cfg.environmentFiles;

        ExecStart = utils.escapeSystemdExecArgs [
          (lib.getExe cfg.package)
          "-nobrowser"
          "-data=${cfg.dataDir}"
        ];

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
      }
      // lib.optionalAttrs (cfg.dataDir == "/var/lib/sonarr/.config/NzbDrone") {
        StateDirectory = "sonarr";
      };

      unitConfig.RequiresMountsFor = [ cfg.dataDir ];
      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.mkIf (cfg.group == "sonarr") {
      sonarr.gid = config.ids.gids.sonarr;
    };

    users.users = lib.mkIf (cfg.user == "sonarr") {
      sonarr = {
        group = cfg.group;
        home = cfg.dataDir;
        uid = config.ids.uids.sonarr;
      };
    };
  };
}
