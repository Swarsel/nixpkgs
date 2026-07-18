{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.rimgo;
  inherit (lib)
    mkOption
    mkEnableOption
    mkPackageOption
    mkIf
    types
    literalExpression
    optionalString
    getExe
    mapAttrs
    ;
in
{
  options.services.rimgo = {
    enable = mkEnableOption "rimgo";
    package = mkPackageOption pkgs "rimgo" { };

    settings = mkOption {
      description = ''
        Settings for rimgo, see [the official documentation](https://rimgo.codeberg.page/docs/usage/configuration/) for supported options.
      '';

      example = literalExpression ''
        {
          PORT = 69420;
          FORCE_WEBP = "1";
        }
      '';

      type = types.submodule {
        options = {
          ADDRESS = mkOption {
            default = "127.0.0.1";
            description = "The address to listen on.";
            example = "1.1.1.1";
            type = types.str;
          };

          PORT = mkOption {
            default = 3000;
            description = "The port to use.";
            example = 69420;
            type = types.port;
          };
        };

        freeformType = with types; attrsOf str;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.rimgo = {
      after = [ "network.target" ];
      description = "Rimgo";
      environment = mapAttrs (_: toString) cfg.settings;

      serviceConfig = {
        AmbientCapabilities = mkIf (cfg.settings.PORT < 1024) [
          "CAP_NET_BIND_SERVICE"
        ];

        CapabilityBoundingSet = [
          (optionalString (cfg.settings.PORT < 1024) "CAP_NET_BIND_SERVICE")
        ];

        DeviceAllow = [ "" ];
        DynamicUser = true;
        ExecStart = getExe cfg.package;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateUsers = cfg.settings.PORT >= 1024;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        Restart = "on-failure";
        RestartSec = "5s";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        UMask = "0077";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ quantenzitrone ];
  };
}
