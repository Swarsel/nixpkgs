{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.koito;

  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;
in
{
  options.services.koito = {
    enable = mkEnableOption "koito";
    package = mkPackageOption pkgs "koito" { };

    environment = mkOption {
      default = { };

      description = ''
        Environment variables to pass to the Koito service.
        See <https://koito.io/reference/configuration/> for available options.
      '';

      example = {
        KOITO_DEFAULT_THEME = "black";
        KOITO_LOGIN_GATE = "true";
      };

      type = types.submodule {
        options = {
          KOITO_BIND_ADDR = mkOption {
            default = "127.0.0.1";
            description = "The IP address to bind the Koito server to.";
            example = "0.0.0.0";
            type = types.str;
          };

          KOITO_CONFIG_DIR = mkOption {
            default = "/var/lib/koito";
            description = "Directory for Koito import folders and image caches.";
            type = types.path;
          };

          KOITO_LISTEN_PORT = mkOption {
            default = 4110;
            description = "TCP port for the Koito server.";
            type = types.port;
          };
        };

        freeformType = types.attrsOf types.str;
      };
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        Path of a file with extra environment variables to be loaded from disk.
        This file is not added to the nix store, so it can be used to pass secrets to Koito.
        See <https://koito.io/reference/configuration/> for available options.
      '';

      example = "/run/secrets/koito";
      type = types.nullOr types.path;
    };

    openFirewall = mkOption {
      default = false;
      description = "Open the appropriate ports in the firewall for Koito.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.environment.KOITO_LISTEN_PORT ];
    };

    systemd.services.koito = {
      after = [ "network-online.target" ];
      description = "Koito - modern scrobbler";

      serviceConfig = {
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        DynamicUser = true;

        Environment = lib.mapAttrsToList (k: v: "${k}=${if builtins.isInt v then toString v else v}") (
          lib.filterAttrs (_: v: v != null) cfg.environment
        );

        EnvironmentFile = cfg.environmentFile;
        ExecStart = getExe cfg.package;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
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

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "koito";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0077";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ iv-nn ];
  };
}
