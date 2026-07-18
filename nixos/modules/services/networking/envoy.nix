{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.envoy;
  format = pkgs.formats.json { };
  conf = format.generate "envoy.json" cfg.settings;
  validateConfig =
    required: file:
    pkgs.runCommand "validate-envoy-conf" { } ''
      ${cfg.package}/bin/envoy --log-level error --mode validate -c "${file}" ${
        lib.optionalString (!required) "|| true"
      }
      cp "${file}" "$out"
    '';
in

{
  options.services.envoy = {
    enable = lib.mkEnableOption "Envoy reverse proxy";
    package = lib.mkPackageOption pkgs "envoy" { };

    requireValidConfig = lib.mkOption {
      default = true;

      description = ''
        Whether a failure during config validation at build time is fatal.
        When the config can't be checked during build time, for example when it includes
        other files, disable this option.
      '';

      type = lib.types.bool;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Specify the configuration for Envoy in Nix.
      '';

      example = lib.literalExpression ''
        {
          admin = {
            access_log_path = "/dev/null";
            address = {
              socket_address = {
                protocol = "TCP";
                address = "127.0.0.1";
                port_value = 9901;
              };
            };
          };
          static_resources = {
            listeners = [];
            clusters = [];
          };
        }
      '';

      type = format.type;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.envoy = {
      after = [ "network-online.target" ];
      description = "Envoy reverse proxy";
      requires = [ "network-online.target" ];

      serviceConfig = {
        # Hardening
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CacheDirectory = [ "envoy" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        DeviceAllow = [ "" ];
        DevicePolicy = "closed";
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/envoy -c ${validateConfig cfg.requireValidConfig conf}";
        LockPersonality = true;
        LogsDirectory = [ "envoy" ];
        MemoryDenyWriteExecute = false; # at least wasmr needs WX permission
        PrivateDevices = true;
        PrivateUsers = false; # breaks CAP_NET_BIND_SERVICE
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "ptraceable";
        ProtectSystem = "strict";
        Restart = "no";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
          "AF_XDP"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0066";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
