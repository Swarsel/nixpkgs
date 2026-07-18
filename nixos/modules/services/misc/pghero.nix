{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.pghero;
  settingsFormat = pkgs.formats.yaml { };
  settingsFile = settingsFormat.generate "pghero.yaml" cfg.settings;
in
{
  options.services.pghero = {
    enable = lib.mkEnableOption "PgHero service";
    package = lib.mkPackageOption pkgs "pghero" { };

    environment = lib.mkOption {
      default = { };

      description = ''
        Environment variables to set for the service. Secrets should be
        specified using {option}`environmentFile`.
      '';

      type = lib.types.attrsOf lib.types.str;
    };

    environmentFiles = lib.mkOption {
      default = [ ];

      description = ''
        File to load environment variables from. Loaded variables override
        values set in {option}`environment`.
      '';

      type = lib.types.listOf lib.types.path;
    };

    extraArgs = lib.mkOption {
      default = [ ];

      description = ''
        Additional command-line arguments for the systemd service.

        Refer to the [Puma web server documentation] for available arguments.

        [Puma web server documentation]: https://puma.io/puma#configuration
      '';

      type = lib.types.listOf lib.types.str;
    };

    extraGroups = lib.mkOption {
      default = [ ];

      description = ''
        Additional groups for the systemd service.
      '';

      example = [ "tlskeys" ];
      type = lib.types.listOf lib.types.str;
    };

    listenAddress = lib.mkOption {
      description = ''
        `hostname:port` to listen for HTTP traffic.

        This is bound using the systemd socket activation.
      '';

      example = "[::1]:3000";
      type = lib.types.str;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        PgHero configuration. Refer to the [PgHero documentation] for more
        details.

        [PgHero documentation]: https://github.com/ankane/pghero/blob/master/guides/Linux.md#multiple-databases
      '';

      example = {
        databases = {
          primary = {
            url = "<%= ENV['PRIMARY_DATABASE_URL'] %>";
          };
        };
      };

      type = settingsFormat.type;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.pghero = {
      after = [
        "pghero.socket"
        "network.target"
      ];

      description = "PgHero performance dashboard for PostgreSQL";

      environment = {
        PGHERO_CONFIG_PATH = settingsFile;
        RAILS_ENV = "production";
      }
      // cfg.environment;

      requires = [ "pghero.socket" ];

      serviceConfig = {
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        DevicePolicy = "closed";
        DynamicUser = true;
        EnvironmentFile = cfg.environmentFiles;

        ExecStart = utils.escapeSystemdExecArgs (
          [
            (lib.getExe cfg.package)
            "--bind-to-activated-sockets"
            "only"
          ]
          ++ cfg.extraArgs
        );

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
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
        Restart = "always";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        SupplementaryGroups = cfg.extraGroups;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = [ "@system-service" ];
        Type = "notify";
        UMask = "0077";
        WatchdogSec = "10";
        WorkingDirectory = "${cfg.package}/share/pghero";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.sockets.pghero = {
      listenStreams = [ cfg.listenAddress ];
      unitConfig.Description = "PgHero HTTP socket";
      wantedBy = [ "sockets.target" ];
    };
  };
}
