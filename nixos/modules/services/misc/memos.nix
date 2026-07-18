{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.memos;
  opt = options.services.memos;
  envFileFormat = pkgs.formats.keyValue { };
in
{
  options.services.memos = {
    enable = lib.mkEnableOption "Memos note-taking";

    package = lib.mkPackageOption pkgs "Memos" {
      default = "memos";
    };

    dataDir = lib.mkOption {
      default = "/var/lib/memos/";

      description = ''
        Specifies the directory where Memos will store its data.

        ::: {.note}
        It will be automatically created with the permissions of [{option}`services.memos.user`](#opt-services.memos.user) and [{option}`services.memos.group`](#opt-services.memos.group).
        :::
      '';

      type = lib.types.path;
    };

    environmentFile = lib.mkOption {
      default = envFileFormat.generate "memos.env" cfg.settings;

      defaultText = lib.literalMD ''
        generated from {option}`${opt.settings}`
      '';

      description = ''
        The environment file to use when starting Memos.

        ::: {.note}
        By default, generated from [](opt-${opt.settings}).
        :::
      '';

      example = "/var/lib/memos/memos.env";
      type = lib.types.path;
    };

    group = lib.mkOption {
      default = "memos";

      description = ''
        The group to run Memos as.

        ::: {.note}
        If changing the default value, **you** are responsible of creating the corresponding group with [{option}`users.groups`](#opt-users.groups).
        :::
      '';

      type = lib.types.str;
    };

    openFirewall = lib.mkEnableOption "opening the ports in the firewall";

    settings = lib.mkOption {
      default = {
        MEMOS_ADDR = "127.0.0.1";
        MEMOS_DATA = cfg.dataDir;
        MEMOS_DRIVER = "sqlite";
        MEMOS_INSTANCE_URL = "http://localhost:5230";
        MEMOS_MODE = "prod";
        MEMOS_PORT = "5230";
      };

      defaultText = lib.literalExpression ''
        {
          MEMOS_MODE = "prod";
          MEMOS_ADDR = "127.0.0.1";
          MEMOS_PORT = "5230";
          MEMOS_DATA = config.${opt.dataDir};
          MEMOS_DRIVER = "sqlite";
          MEMOS_INSTANCE_URL = "http://localhost:5230";
        }
      '';

      description = ''
        The environment variables to configure Memos.

        ::: {.note}
        At time of writing, there is no clear documentation about possible values.
        It's possible to convert CLI flags into these variables.
        Example : CLI flag "--unix-sock" converts to {env}`MEMOS_UNIX_SOCK`.
        :::
      '';

      type = envFileFormat.type;
    };

    user = lib.mkOption {
      default = "memos";

      description = ''
        The user to run Memos as.

        ::: {.note}
        If changing the default value, **you** are responsible of creating the corresponding user with [{option}`users.users`](#opt-users.users).
        :::
      '';

      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      cfg.port
    ];

    systemd.services.memos = {
      after = [ "network.target" ];
      description = "Memos, a privacy-first, lightweight note-taking solution";

      serviceConfig = {
        CapabilityBoundingSet = [
          " " # Reset all capabilities to an empty set
        ];

        DevicePolicy = "closed";
        EnvironmentFile = cfg.environmentFile;
        ExecStart = lib.getExe cfg.package;
        Group = cfg.group;
        LimitNOFILE = 65536;
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
        ProtectSystem = "strict";

        ReadWritePaths = [
          cfg.dataDir
        ];

        RemoveIPC = true;
        RestartSec = 60;

        RestrictAddressFamilies = [
          " " # This is needed to clear the RestrictAddressFamilies existing definitions
          "none" # Remove all addresses families
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          " " # This is needed to clear the SystemCallFilter existing definitions
          "~@reboot"
          "~@swap"
          "~@obsolete"
          "~@mount"
          "~@module"
          "~@debug"
          "~@cpu-emulation"
          "~@clock"
          "~@raw-io"
          "~@privileged"
          "~@resources"
        ];

        Type = "simple";
        UMask = "0077";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
    };

    systemd.tmpfiles.settings."10-memos" = {
      "${cfg.dataDir}" = {
        d = {
          group = cfg.group;
          mode = "0750";
          user = cfg.user;
        };
      };
    };

    users.groups = lib.mkIf (cfg.group == "memos") {
      ${cfg.group} = { };
    };

    users.users = lib.mkIf (cfg.user == "memos") {
      ${cfg.user} = {
        description = lib.mkDefault "Memos service user";
        group = cfg.group;
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = [ lib.maintainers.M0ustach3 ];
}
