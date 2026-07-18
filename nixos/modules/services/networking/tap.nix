{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.tap;
in
{
  options.services.tap = {
    enable = lib.mkEnableOption "Tap, ATProtocol firehose sync utility";
    package = lib.mkPackageOption pkgs "tap" { };

    environmentFiles = lib.mkOption {
      default = [ ];

      description = ''
        Files to load environment variables from. Use for secrets such as
        {env}`TAP_ADMIN_PASSWORD` that should not be readable in the Nix store.
      '';

      type = lib.types.listOf lib.types.path;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration for Tap as environment variables. See the
        [README](https://github.com/bluesky-social/indigo/blob/main/cmd/tap/README.md)
        for all available options.

        Secrets such as {option}`settings.TAP_ADMIN_PASSWORD` should be set via
        {option}`environmentFiles` rather than here, as values set here will
        be readable in the Nix store.
      '';

      type = lib.types.submodule {
        options = {
          TAP_BIND = lib.mkOption {
            default = "127.0.0.1:2480";
            description = "Address and port the HTTP server will listen on.";
            type = lib.types.str;
          };

          TAP_DATABASE_URL = lib.mkOption {
            default = "sqlite:///var/lib/tap/tap.db";

            description = ''
              Database connection string. Accepts SQLite (`sqlite://path`) or
              PostgreSQL (`postgres://...`) connection strings.
            '';

            type = lib.types.str;
          };
        };

        freeformType = lib.types.attrsOf (
          lib.types.nullOr (
            lib.types.oneOf [
              lib.types.bool
              lib.types.int
              lib.types.float
              lib.types.str
            ]
          )
        );
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.tap = {
      after = [ "network-online.target" ];
      description = "Tap - ATProtocol firehose sync utility";

      serviceConfig = {
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        DynamicUser = true;

        Environment = lib.mapAttrsToList (
          k: v: "${k}=${if lib.isBool v then lib.boolToString v else toString v}"
        ) (lib.filterAttrs (_: v: v != null) cfg.settings);

        EnvironmentFile = cfg.environmentFiles;
        ExecStart = "${lib.getExe cfg.package} run";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
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
        ProtectSystem = "strict";
        RemoveIPC = true;
        Restart = "on-failure";
        RestartSec = 5;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "tap";
        StateDirectoryMode = "0750";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        UMask = "0077";
        User = "tap";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ blooym ];
}
