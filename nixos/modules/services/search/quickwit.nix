{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.quickwit;

  settingsFormat = pkgs.formats.yaml { };
  quickwitYml = settingsFormat.generate "quickwit.yml" cfg.settings;

  usingDefaultDataDir = cfg.dataDir == "/var/lib/quickwit";
  usingDefaultUserAndGroup = cfg.user == "quickwit" && cfg.group == "quickwit";
in
{

  options.services.quickwit = {
    enable = lib.mkEnableOption "Quickwit";

    package = lib.mkPackageOption pkgs "Quickwit" {
      default = [ "quickwit" ];
    };

    dataDir = lib.mkOption {
      apply = lib.converge (lib.removeSuffix "/");
      default = "/var/lib/quickwit";

      description = ''
        Data directory for Quickwit. If you change this, you need to
        manually create the directory. You also need to create the
        `quickwit` user and group, or change
        [](#opt-services.quickwit.user) and
        [](#opt-services.quickwit.group) to existing ones with
        access to the directory.
      '';

      type = lib.types.path;
    };

    extraFlags = lib.mkOption {
      default = [ ];
      description = "Extra command line options to pass to Quickwit.";
      type = lib.types.listOf lib.types.str;
    };

    group = lib.mkOption {
      default = "quickwit";

      description = ''
        The group quickwit runs as. Should be left at default unless
        you have very specific needs.
      '';

      type = lib.types.str;
    };

    restartIfChanged = lib.mkOption {
      default = true;

      description = ''
        Automatically restart the service on config change.
        This can be set to false to defer restarts on a server or cluster.
        Please consider the security implications of inadvertently running an older version,
        and the possibility of unexpected behavior caused by inconsistent versions across a cluster when disabling this option.
      '';

      type = lib.types.bool;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Quickwit configuration.
      '';

      type = lib.types.submodule {
        options."grpc_listen_port" = lib.mkOption {
          default = 7281;

          description = ''
            The port to listen on for gRPC traffic.
          '';

          type = lib.types.port;
        };

        options."listen_address" = lib.mkOption {
          default = "127.0.0.1";

          description = ''
            Listen address of Quickwit.
          '';

          type = lib.types.str;
        };

        options."rest" = lib.mkOption {
          default = { };

          description = ''
            Rest server configuration for Quickwit
          '';

          type = lib.types.submodule {
            options."listen_port" = lib.mkOption {
              default = 7280;

              description = ''
                The port to listen on for HTTP REST traffic.
              '';

              type = lib.types.port;
            };

            freeformType = settingsFormat.type;
          };
        };

        options."version" = lib.mkOption {
          default = 0.7;

          description = ''
            Configuration file version.
          '';

          type = lib.types.float;
        };

        freeformType = settingsFormat.type;
      };
    };

    user = lib.mkOption {
      default = "quickwit";

      description = ''
        The user Quickwit runs as. Should be left at default unless
        you have very specific needs.
      '';

      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.quickwit = {
      inherit (cfg) restartIfChanged;
      after = [ "network.target" ];
      description = "Quickwit";

      environment = {
        QW_DATA_DIR = cfg.dataDir;
      };

      serviceConfig = {
        CapabilityBoundingSet = [ "" ];
        DevicePolicy = "closed";
        DynamicUser = usingDefaultUserAndGroup && usingDefaultDataDir;

        ExecStart = ''
          ${cfg.package}/bin/quickwit run --config ${quickwitYml} \
          ${lib.escapeShellArgs cfg.extraFlags}
        '';

        Group = cfg.group;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
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

        ReadWritePaths = [
          cfg.dataDir
        ];

        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_NETLINK"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          # 1. allow a reasonable set of syscalls
          "@system-service @resources"
          # 2. and deny unreasonable ones
          "~@privileged"
          # 3. then allow the required subset within denied groups
          "@chown"
        ];

        User = cfg.user;
      }
      // (lib.optionalAttrs usingDefaultDataDir {
        StateDirectory = "quickwit";
        StateDirectoryMode = "0700";
      });

      wantedBy = [ "multi-user.target" ];
    };
  };
}
