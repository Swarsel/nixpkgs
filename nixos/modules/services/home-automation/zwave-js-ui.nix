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
    mkEnableOption
    mkOption
    mkPackageOption
    types
    ;
  cfg = config.services.zwave-js-ui;
in
{
  options.services.zwave-js-ui = {
    enable = mkEnableOption "zwave-js-ui";
    package = mkPackageOption pkgs "zwave-js-ui" { };

    serialPort = mkOption {
      description = ''
        Serial port for the Z-Wave controller.

        Only used to grant permissions to the device; must be additionally configured in the application
      '';

      example = "/dev/serial/by-id/usb-example";
      type = types.path;
    };

    settings = mkOption {
      description = ''
        Extra environment variables passed to the zwave-js-ui process.

        Check <https://zwave-js.github.io/zwave-js-ui/#/guide/env-vars> for possible options
      '';

      example = {
        HOST = "::";
        PORT = "8091";
      };

      type = types.submodule {
        options = {
          STORE_DIR = mkOption {
            default = "%S/zwave-js-ui";
            readOnly = true;
            type = types.str;
            visible = false;
          };

          ZWAVEJS_EXTERNAL_CONFIG = mkOption {
            default = "%S/zwave-js-ui/.config-db";
            readOnly = true;
            type = types.str;
            visible = false;
          };
        };

        freeformType =
          with types;
          attrsOf (
            nullOr (oneOf [
              str
              path
              package
            ])
          );
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.zwave-js-ui = {
      environment = cfg.settings;

      serviceConfig = {
        BindReadOnlyPaths = [
          "/nix/store"
        ];

        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ cfg.serialPort ];
        DevicePolicy = "closed";
        DynamicUser = true;
        ExecStart = getExe cfg.package;
        LockPersonality = true;
        MemoryDenyWriteExecute = false;
        NoNewPrivileges = true;
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
        RemoveIPC = true;
        RestrictAddressFamilies = "AF_INET AF_INET6";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RootDirectory = "%t/zwave-js-ui";
        RuntimeDirectory = "zwave-js-ui";
        StateDirectory = "zwave-js-ui";
        SupplementaryGroups = [ "dialout" ];
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service @pkey"
          "~@privileged @resources"
          "@chown"
        ];

        UMask = "0077";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ cdombroski ];
}
