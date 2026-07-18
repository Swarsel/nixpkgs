{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    ;

  cfg = config.services.evcc;

  format = pkgs.formats.yaml { };
  configFile = format.generate "evcc.yml" cfg.settings;

  package = pkgs.evcc;
in

{
  options.services.evcc = with lib.types; {
    enable = mkEnableOption "EVCC, the extensible EV Charge Controller and Home Energy Management System";
    package = mkPackageOption pkgs "evcc" { };

    environmentFile = mkOption {
      default = null;

      description = ''
        File with environment variables to pass into the runtime environment.

        Useful to pass secrets into the configuration, that get applied using `envsubst`.
      '';

      example = "/run/keys/evcc";
      type = nullOr path;
    };

    extraArgs = mkOption {
      default = [ ];

      description = ''
        Extra arguments to pass to the `evcc` executable.
      '';

      type = listOf str;
    };

    settings = mkOption {
      description = ''
        evcc configuration as a Nix attribute set. Supports substitution of secrets using `envsubst` from the `environmentFile`.

        Check for possible options in the sample [evcc.dist.yaml](https://github.com/andig/evcc/blob/${package.version}/evcc.dist.yaml).
      '';

      type = format.type;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.evcc = {
      after = [
        "network-online.target"
        "mosquitto.target"
      ];

      environment.HOME = "/var/lib/evcc";

      path = with pkgs; [
        getent
      ];

      serviceConfig = {
        CapabilityBoundingSet = [ "" ];

        DeviceAllow = [
          "char-ttyUSB"
        ];

        DevicePolicy = "closed";
        DynamicUser = true;
        EnvironmentFile = lib.optionals (cfg.environmentFile != null) [ cfg.environmentFile ];

        ExecStart = utils.escapeSystemdExecArgs (
          [
            (getExe cfg.package)
            "--config=/run/evcc/config.yaml"
          ]
          ++ cfg.extraArgs
        );

        ExecStartPre = utils.escapeSystemdExecArgs [
          (getExe pkgs.envsubst)
          "-i"
          configFile
          "-o"
          "/run/evcc/config.yaml"
        ];

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
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
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
          "AF_NETLINK"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RuntimeDirectory = "evcc";
        StateDirectory = "evcc";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        UMask = "0077";
        User = "evcc";
      };

      wantedBy = [
        "multi-user.target"
      ];

      wants = [ "network-online.target" ];
    };
  };

  meta.buildDocsInSandbox = false;
  meta.maintainers = with lib.maintainers; [ hexa ];
}
