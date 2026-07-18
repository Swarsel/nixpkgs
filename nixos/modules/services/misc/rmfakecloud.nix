{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.rmfakecloud;
  serviceDataDir = "/var/lib/rmfakecloud";

in
{
  options = {
    services.rmfakecloud = {
      enable = lib.mkEnableOption "rmfakecloud remarkable self-hosted cloud";
      package = lib.mkPackageOption pkgs "rmfakecloud" { };

      environmentFile = lib.mkOption {
        default = null;

        description = ''
          Path to an environment file loaded for the rmfakecloud service.

          This can be used to securely store tokens and secrets outside of the
          world-readable Nix store. Since this file is read by systemd, it may
          have permission 0400 and be owned by root.
        '';

        example = "/etc/secrets/rmfakecloud.env";
        type = with lib.types; nullOr path;
      };

      extraSettings = lib.mkOption {
        default = { };

        description = ''
          Extra settings in the form of a set of key-value pairs.
          For tokens and secrets, use `environmentFile` instead.

          Available settings are listed on
          https://ddvk.github.io/rmfakecloud/install/configuration/.
        '';

        example = {
          DATADIR = "/custom/path/for/rmfakecloud/data";
        };

        type = with lib.types; attrsOf str;
      };

      logLevel = lib.mkOption {
        default = "info";

        description = ''
          Logging level.
        '';

        type = lib.types.enum [
          "info"
          "debug"
          "warn"
          "error"
        ];
      };

      port = lib.mkOption {
        default = 3000;

        description = ''
          Listening port number.
        '';

        type = lib.types.port;
      };

      storageUrl = lib.mkOption {
        description = ''
          URL used by the tablet to access the rmfakecloud service.
        '';

        example = "https://local.appspot.com";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.rmfakecloud = {
      after = [ "network-online.target" ];
      description = "rmfakecloud remarkable self-hosted cloud";

      environment = {
        LOGLEVEL = cfg.logLevel;
        PORT = toString cfg.port;
        STORAGE_URL = cfg.storageUrl;
      }
      // cfg.extraSettings;

      preStart = ''
        # Generate the secret key used to sign client session tokens.
        # Replacing it invalidates the previously established sessions.
        if [ -z "$JWT_SECRET_KEY" ] && [ ! -f jwt_secret_key ]; then
          (umask 077; touch jwt_secret_key)
          cat /dev/urandom | tr -cd '[:alnum:]' | head -c 48 >> jwt_secret_key
        fi
      '';

      script = ''
        if [ -z "$JWT_SECRET_KEY" ]; then
          export JWT_SECRET_KEY="$(cat jwt_secret_key)"
        fi

        ${cfg.package}/bin/rmfakecloud
      '';

      serviceConfig = {
        AmbientCapabilities = lib.mkIf (cfg.port < 1024) [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "" ];
        DevicePolicy = "closed";
        DynamicUser = true;
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
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
        Restart = "always";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = baseNameOf serviceDataDir;
        SystemCallArchitectures = "native";
        Type = "simple";
        UMask = "0027";
        WorkingDirectory = serviceDataDir;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ martinetd ];
}
