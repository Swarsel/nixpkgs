{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.centrifugo;

  settingsFormat = pkgs.formats.json { };

  configFile = settingsFormat.generate "centrifugo.json" cfg.settings;
in
{
  options.services.centrifugo = {
    enable = lib.mkEnableOption "Centrifugo messaging server";
    package = lib.mkPackageOption pkgs "centrifugo" { };

    credentials = lib.mkOption {
      default = { };

      description = ''
        Environment variables with absolute paths to credentials files to load
        on service startup.
      '';

      example = {
        CENTRIFUGO_UNI_GRPC_TLS_KEY = "/run/keys/centrifugo-uni-grpc-tls.key";
      };

      type = lib.types.attrsOf lib.types.path;
    };

    environmentFiles = lib.mkOption {
      default = [ ];

      description = ''
        Files to load environment variables from. Options set via environment
        variables take precedence over {option}`settings`.

        See the [Centrifugo documentation] for the environment variable name
        format.

        [Centrifugo documentation]: https://centrifugal.dev/docs/server/configuration#os-environment-variables
      '';

      type = lib.types.listOf lib.types.path;
    };

    extraGroups = lib.mkOption {
      default = [ ];

      description = ''
        Additional groups for the systemd service.
      '';

      example = [ "redis-centrifugo" ];
      type = lib.types.listOf lib.types.str;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Declarative Centrifugo configuration. See the [Centrifugo
        documentation] for a list of options.

        [Centrifugo documentation]: https://centrifugal.dev/docs/server/configuration
      '';

      type = settingsFormat.type;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          (lib.versionAtLeast cfg.package.version "6") -> (!(cfg.settings ? name) && !(cfg.settings ? port));

        message = "`services.centrifugo.settings` is v5 config, must be compatible with centrifugo v6 config format";
      }
    ];

    systemd.services.centrifugo = {
      after = [ "network.target" ];
      description = "Centrifugo messaging server";

      serviceConfig = {
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        DevicePolicy = "closed";
        DynamicUser = true;
        Environment = lib.mapAttrsToList (name: _: "${name}=%d/${name}") cfg.credentials;
        EnvironmentFile = cfg.environmentFiles;
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = "${lib.getExe cfg.package} --config ${configFile}";
        ExecStartPre = "${lib.getExe cfg.package} checkconfig --config ${configFile}";
        # Copy files to the credentials directory with file name being the
        # environment variable name. Note that "%d" specifier expands to the
        # path of the credentials directory.
        LoadCredential = lib.mapAttrsToList (name: value: "${name}:${value}") cfg.credentials;
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
        RestartSec = "1s";

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

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        Type = "exec";
        UMask = "0077";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
