{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.temporal;

  settingsFormat = pkgs.formats.yaml { };

  usingDefaultDataDir = cfg.dataDir == "/var/lib/temporal";
  usingDefaultUserAndGroup = cfg.user == "temporal" && cfg.group == "temporal";
in
{
  options.services.temporal = {
    enable = lib.mkEnableOption "Temporal";

    package = lib.mkPackageOption pkgs "Temporal" {
      default = [ "temporal" ];
    };

    dataDir = lib.mkOption {
      apply = lib.converge (lib.removeSuffix "/");
      default = "/var/lib/temporal";

      description = ''
        Data directory for Temporal. If you change this, you need to
        manually create the directory. You also need to create the
        `temporal` user and group, or change
        [](#opt-services.temporal.user) and
        [](#opt-services.temporal.group) to existing ones with
        access to the directory.
      '';

      type = lib.types.path;
    };

    group = lib.mkOption {
      default = "temporal";

      description = ''
        The group temporal runs as. Should be left at default unless
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
      description = ''
        Temporal configuration.

        See <https://docs.temporal.io/references/configuration> for more
        information about Temporal configuration options
      '';

      type = lib.types.submodule {
        freeformType = settingsFormat.type;
      };
    };

    user = lib.mkOption {
      default = "temporal";

      description = ''
        The user Temporal runs as. Should be left at default unless
        you have very specific needs.
      '';

      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."temporal/temporal-server.yaml".source =
      settingsFormat.generate "temporal-server.yaml" cfg.settings;

    systemd.services.temporal = {
      inherit (cfg) restartIfChanged;
      after = [ "network.target" ];
      description = "Temporal server";

      environment = {
        HOME = cfg.dataDir;
      };

      restartTriggers = [ config.environment.etc."temporal/temporal-server.yaml".source ];

      serviceConfig = {
        CapabilityBoundingSet = [ "" ];
        DevicePolicy = "closed";
        DynamicUser = usingDefaultUserAndGroup && usingDefaultDataDir;

        ExecStart = ''
          ${cfg.package}/bin/temporal-server --root / --config /etc/temporal/ -e temporal-server start
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
        StateDirectory = "temporal";
        StateDirectoryMode = "0700";
      });

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.jpds ];
}
