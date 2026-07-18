{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.go-httpbin;

  environment = lib.mapAttrs (
    _: value: if lib.isBool value then lib.boolToString value else toString value
  ) cfg.settings;
in

{
  options.services.go-httpbin = {
    enable = lib.mkEnableOption "go-httpbin";
    package = lib.mkPackageOption pkgs "go-httpbin" { };

    settings = lib.mkOption {
      description = ''
        Configuration of go-httpbin.
        See <https://github.com/mccutchen/go-httpbin#configuration> for a list of options.
      '';

      example = {
        HOST = "0.0.0.0";
        PORT = 8080;
      };

      type = lib.types.submodule {
        options = {
          HOST = lib.mkOption {
            default = "127.0.0.1";
            description = "The host to listen on.";
            example = "0.0.0.0";
            type = lib.types.str;
          };

          PORT = lib.mkOption {
            description = "The port to listen on.";
            example = 8080;
            type = lib.types.port;
          };
        };

        freeformType =
          with lib.types;
          attrsOf (oneOf [
            str
            int
            bool
          ]);
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.go-httpbin = {
      inherit environment;

      serviceConfig = {
        # hardening
        AmbientCapabilities = "";
        CapabilityBoundingSet = [ "" ];
        DevicePolicy = "closed";
        DynamicUser = true;
        ExecStart = lib.getExe cfg.package;
        Group = "go-httpbin";
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
        RestrictAddressFamilies = [ "AF_INET AF_INET6" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SocketBindAllow = "tcp:${toString cfg.settings.PORT}";
        SocketBindDeny = "any";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0077";
        User = "go-httpbin";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ defelo ];
}
