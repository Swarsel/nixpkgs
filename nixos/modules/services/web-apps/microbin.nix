{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.microbin;
in
{
  options.services.microbin = {
    enable = lib.mkEnableOption "MicroBin is a super tiny, feature rich, configurable paste bin web application";
    package = lib.mkPackageOption pkgs "microbin" { };

    dataDir = lib.mkOption {
      default = "/var/lib/microbin";
      description = "Default data folder for MicroBin.";
      type = lib.types.str;
    };

    passwordFile = lib.mkOption {
      default = null;

      description = ''
        Path to file containing environment variables.
        Useful for passing down secrets.
        Variables that can be considered secrets are:
         - MICROBIN_BASIC_AUTH_USERNAME
         - MICROBIN_BASIC_AUTH_PASSWORD
         - MICROBIN_ADMIN_USERNAME
         - MICROBIN_ADMIN_PASSWORD
         - MICROBIN_UPLOADER_PASSWORD
      '';

      example = "/run/secrets/microbin.env";
      type = lib.types.nullOr lib.types.path;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Additional configuration for MicroBin, see
        <https://microbin.eu/docs/installation-and-configuration/configuration/>
        for supported values.

        For secrets use passwordFile option instead.
      '';

      example = {
        MICROBIN_HIDE_LOGO = false;
        MICROBIN_PORT = 8080;
      };

      type = lib.types.submodule {
        freeformType =
          with lib.types;
          attrsOf (oneOf [
            bool
            int
            str
          ]);
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.microbin.settings = with lib; {
      MICROBIN_BIND = mkDefault "0.0.0.0";
      MICROBIN_DISABLE_TELEMETRY = mkDefault true;
      MICROBIN_LIST_SERVER = mkDefault false;
      MICROBIN_PORT = mkDefault "8080";
    };

    systemd.services.microbin = {
      after = [ "network.target" ];

      environment = lib.mapAttrs (
        _: v: if lib.isBool v then lib.boolToString v else toString v
      ) cfg.settings;

      serviceConfig = {
        DevicePolicy = "closed";
        DynamicUser = true;
        EnvironmentFile = lib.optional (cfg.passwordFile != null) cfg.passwordFile;
        ExecStart = "${cfg.package}/bin/microbin";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ReadWritePaths = cfg.dataDir;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "microbin";
        SystemCallArchitectures = [ "native" ];
        SystemCallFilter = [ "@system-service" ];
        WorkingDirectory = cfg.dataDir;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ surfaceflinger ];
}
