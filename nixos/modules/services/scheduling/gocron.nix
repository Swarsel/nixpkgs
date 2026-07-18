{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.gocron;
  settingsFormat = pkgs.formats.yaml { };
  gocronConf = settingsFormat.generate "gocron.yaml" cfg.settings;
  defaultUser = "gocron";
  defaultGroup = "gocron";
  timeZone = config.time.timeZone;

  hardeningOptions = lib.mkOption {
    description = "Configuration for hardening the systemd service.";

    type = lib.types.submodule {
      options = {
        ProtectHome = lib.mkOption {
          default = true;

          description = ''
            Whether to make the home directories inaccessible to the service.
            See <link xlink:href="https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#ProtectHome="/> for more details.
          '';

          example = "read-only";
          type = lib.types.either lib.types.str lib.types.bool;
        };

        ProtectSystem = lib.mkOption {
          default = true;

          description = ''
            Whether to make several system directories inaccessible to the service.
            See <link xlink:href="https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#ProtectSystem="/> for more details.
          '';

          example = "full";
          type = lib.types.either lib.types.str lib.types.bool;
        };
      };
    };
  };
in
{

  options.services.gocron = {
    enable = lib.mkEnableOption "gocron, a task scheduler";

    package = lib.mkOption {
      default = pkgs.gocron;
      defaultText = lib.literalExpression "pkgs.gocron";

      description = ''
        gocron package to use.
      '';

      type = lib.types.package;
    };

    extraGroups = lib.mkOption {
      default = [ ];

      description = ''
        Additional groups for the systemd service.
      '';

      example = [ "backup" ];
      type = lib.types.listOf lib.types.str;
    };

    group = lib.mkOption {
      default = defaultGroup;
      description = "Unix Group to run the server under";
      type = lib.types.str;
    };

    hardening = hardeningOptions;

    openFirewall = lib.mkOption {
      default = false;
      description = "Whether to open the firewall port to access the web ui.";
      type = lib.types.bool;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration for gocron, see
        <link xlink:href="https://github.com/flohoss/gocron/blob/main/config/config.yaml"/>
        for supported settings.
      '';

      # Setting this type allows for correct merging behavior
      type = settingsFormat.type;
    };

    user = lib.mkOption {
      default = defaultUser;
      description = "Unix User to run the server under";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !lib.hasAttr "software" cfg.settings;
        message = "Software installation configuration is only supported for traditional distros by upstream.";
      }
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.settings.server.port ];

    services.gocron.settings = {
      db.location = lib.mkDefault "/var/lib/gocron";

      server = {
        address = lib.mkDefault "127.0.0.1";
        port = lib.mkDefault 8156;
      };

      time_zone = if timeZone != null then timeZone else lib.mkDefault "Etc/UTC";
    };

    systemd.services.gocron = {
      after = [ "network.target" ];

      serviceConfig = {
        DeviceAllow = "";
        ExecStart = "${lib.getExe pkgs.gocron} --config '${gocronConf}'";
        Group = cfg.group;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        MountAPIVFS = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateNetwork = lib.mkDefault false;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = cfg.hardening.ProtectHome;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = cfg.hardening.ProtectSystem;
        RemoveIPC = true;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = lib.mkIf (cfg.settings.db.location == "/var/lib/gocron") "gocron";
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";

        SystemCallFilter = [
          "@system-service"
        ];

        UMask = "0077";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      inherit (cfg) group;
      isSystemUser = true;
    };

    meta = {
      buildDocsInSandbox = true;
      maintainers = with lib.maintainers; [ juliusfreudenberger ];
    };
  };
}
