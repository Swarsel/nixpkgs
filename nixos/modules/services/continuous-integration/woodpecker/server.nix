{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.woodpecker-server;
in
{
  options = {
    services.woodpecker-server = {
      enable = lib.mkEnableOption "the Woodpecker-Server, a CI/CD application for automatic builds, deployments and tests";
      package = lib.mkPackageOption pkgs "woodpecker-server" { };

      environment = lib.mkOption {
        default = { };
        description = "woodpecker-server config environment variables, for other options read the [documentation](https://woodpecker-ci.org/docs/administration/configuration/server)";

        example = lib.literalExpression ''
          {
            WOODPECKER_HOST = "https://woodpecker.example.com";
            WOODPECKER_OPEN = "true";
            WOODPECKER_GITEA = "true";
            WOODPECKER_GITEA_CLIENT = "ffffffff-ffff-ffff-ffff-ffffffffffff";
            WOODPECKER_GITEA_URL = "https://git.example.com";
          }
        '';

        type = lib.types.attrsOf lib.types.str;
      };

      environmentFile = lib.mkOption {
        default = [ ];

        description = ''
          File to load environment variables
          from. This is helpful for specifying secrets.
          Example content of environmentFile:
          ```
          WOODPECKER_AGENT_SECRET=your-shared-secret-goes-here
          WOODPECKER_GITEA_SECRET=gto_**************************************
          ```
        '';

        example = [ "/root/woodpecker-server.env" ];
        type = with lib.types; coercedTo path (f: [ f ]) (listOf path);
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = {
      woodpecker-server = {
        inherit (cfg) environment;
        after = [ "network-online.target" ];
        description = "Woodpecker-Server Service";

        serviceConfig = {
          CapabilityBoundingSet = "";
          ConfigurationDirectory = "woodpecker-server";
          DynamicUser = true;
          EnvironmentFile = cfg.environmentFile;
          ExecStart = lib.getExe cfg.package;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          # Security
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          # Sandboxing
          ProtectSystem = "strict";
          Restart = "on-failure";
          RestartSec = 15;
          RestrictAddressFamilies = [ "AF_UNIX AF_INET AF_INET6" ];
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          StateDirectory = "woodpecker-server";
          StateDirectoryMode = "0700";
          # System Call Filtering
          SystemCallArchitectures = "native";
          SystemCallFilter = "~@clock @privileged @cpu-emulation @debug @keyring @module @mount @obsolete @raw-io @reboot @setuid @swap";
          UMask = "0007";
          WorkingDirectory = "%S/woodpecker-server";
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ ambroisie ];
}
