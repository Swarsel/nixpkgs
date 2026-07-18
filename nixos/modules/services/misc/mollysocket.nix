{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    getExe
    mkIf
    mkOption
    mkEnableOption
    types
    ;

  cfg = config.services.mollysocket;
  configuration = format.generate "mollysocket.conf" cfg.settings;
  format = pkgs.formats.toml { };
  package = pkgs.writeShellScriptBin "mollysocket" ''
    MOLLY_CONF=${configuration} exec ${getExe pkgs.mollysocket} "$@"
  '';
in
{
  options.services.mollysocket = {
    enable = mkEnableOption ''
      [MollySocket](https://github.com/mollyim/mollysocket) for getting Signal
      notifications via UnifiedPush
    '';

    environmentFile = mkOption {
      default = null;

      description = ''
        Environment file (see {manpage}`systemd.exec(5)` "EnvironmentFile="
        section for the syntax) passed to the service. This option can be
        used to safely include secrets in the configuration.
      '';

      example = "/run/secrets/mollysocket";
      type = with types; nullOr path;
    };

    logLevel = mkOption {
      default = "info";
      description = "Set the {env}`RUST_LOG` environment variable";
      example = "debug";
      type = types.str;
    };

    settings = mkOption {
      default = { };

      description = ''
        Configuration for MollySocket. Available options are listed
        [here](https://github.com/mollyim/mollysocket#configuration).
      '';

      type = types.submodule {
        options = {
          allowed_endpoints = mkOption {
            default = [ "*" ];
            description = "List of UnifiedPush servers";
            example = [ "https://ntfy.sh" ];
            type = with types; listOf str;
          };

          allowed_uuids = mkOption {
            default = [ "*" ];
            description = "UUIDs of Signal accounts that may use this server";
            example = [ "abcdef-12345-tuxyz-67890" ];
            type = with types; listOf str;
          };

          host = mkOption {
            default = "127.0.0.1";
            description = "Listening address of the web server";
            type = types.str;
          };

          port = mkOption {
            default = 8020;
            description = "Listening port of the web server";
            type = types.port;
          };
        };

        freeformType = format.type;
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      package
    ];

    # see https://github.com/mollyim/mollysocket/blob/main/mollysocket.service
    systemd.services.mollysocket = {
      after = [ "network-online.target" ];
      description = "MollySocket";
      environment.RUST_LOG = cfg.logLevel;

      serviceConfig = {
        # hardening
        DevicePolicy = "closed";
        DynamicUser = true;
        EnvironmentFile = cfg.environmentFile;
        ExecStart = "${getExe package} server";
        KillSignal = "SIGINT";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
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

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "mollysocket";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@resources"
          "~@privileged"
        ];

        TimeoutStopSec = 5;
        UMask = "0077";
        WorkingDirectory = "/var/lib/mollysocket";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ dotlambda ];
}
