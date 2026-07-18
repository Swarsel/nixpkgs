{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.services.send;
in
{
  options = {
    services.send = {
      enable = lib.mkEnableOption "Send, a file sharing web sevice for ffsend.";
      package = lib.mkPackageOption pkgs "send" { };

      baseUrl = mkOption {
        default = null;

        description = ''
          Base URL for the Send service.
          Leave it blank to automatically detect the base url.
        '';

        type = types.nullOr types.str;
      };

      dataDir = lib.mkOption {
        default = "/var/lib/send";

        description = ''
          Directory for uploaded files.
          Due to limitations in {option}`systemd.services.send.serviceConfig.DynamicUser`, this item is read only.
        '';

        readOnly = true;
        type = types.path;
      };

      environment = mkOption {
        description = ''
          All the available config options and their defaults can be found here: <https://github.com/timvisee/send/blob/master/server/config.js>,
          some descriptions can found here: <https://github.com/timvisee/send/blob/master/docs/docker.md#environment-variables>

          Values under {option}`services.send.environment` will override the predefined values in the Send service.
            - Time/duration should be in seconds
            - Filesize values should be in bytes
        '';

        example = {
          DEFAULT_DOWNLOADS = 1;
          DETECT_BASE_URL = true;

          EXPIRE_TIMES_SECONDS = [
            300
            3600
            86400
            604800
          ];
        };

        type =
          with types;
          attrsOf (
            nullOr (oneOf [
              bool
              int
              str
              (listOf int)
            ])
          );
      };

      environmentFile = mkOption {
        default = null;

        description = ''
          Environment file (see {manpage}`systemd.exec(5)` "EnvironmentFile="
          section for the syntax) passed to the service. This option is the
          recommended way to pass secrets to Send.

          This is especially important for users using a cloud storage backend.

          A list of environment variables recognized by Send can be found here:
          <https://github.com/timvisee/send/blob/master/docs/docker.md>
        '';

        example = "/run/secrets/send";
        type = with types; nullOr path;
      };

      host = lib.mkOption {
        default = "127.0.0.1";
        description = "The hostname or IP address for Send to bind to.";
        type = types.str;
      };

      openFirewall = lib.mkOption {
        default = false;
        description = "Whether to open firewall ports for send";
        type = types.bool;
      };

      port = lib.mkOption {
        default = 1443;
        description = "Port the Send service listens on.";
        type = types.port;
      };

      redis = {
        createLocally = lib.mkOption {
          default = true;
          description = "Whether to create a local redis automatically.";
          type = types.bool;
        };

        host = lib.mkOption {
          default = "localhost";
          description = "Redis server address.";
          type = types.str;
        };

        name = lib.mkOption {
          default = "send";

          description = ''
            Name of the redis server.
            Only used if {option}`services.send.redis.createLocally` is set to true.
          '';

          type = types.str;
        };

        passwordFile = mkOption {
          default = null;

          description = ''
            The path to the file containing the Redis password.

            If {option}`services.send.redis.createLocally` is set to true,
            the content of this file will be used as the password for the locally created Redis instance.

            Leave it blank if no password is required.
          '';

          example = "/run/agenix/send-redis-password";
          type = types.nullOr types.path;
        };

        port = lib.mkOption {
          default = 6379;
          description = "Port of the redis server.";
          type = types.port;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.redis.createLocally -> cfg.redis.host == "localhost";
        message = "the redis host must be localhost if services.send.redis.createLocally is set to true";
      }
    ];

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;

    services.redis = lib.optionalAttrs cfg.redis.createLocally {
      servers."${cfg.redis.name}" = {
        enable = true;
        bind = "localhost";
        port = cfg.redis.port;
      };
    };

    services.send.environment.DETECT_BASE_URL = cfg.baseUrl == null;

    systemd.services.send = {
      after = [
        "network.target"
      ]
      ++ lib.optionals cfg.redis.createLocally [
        "redis-${cfg.redis.name}.service"
      ];

      description = "Send web service";

      environment = {
        BASE_URL = if (cfg.baseUrl == null) then "http://${cfg.host}:${toString cfg.port}" else cfg.baseUrl;
        FILE_DIR = cfg.dataDir + "/uploads";
        IP_ADDRESS = cfg.host;
        PORT = toString cfg.port;
        REDIS_HOST = cfg.redis.host;
        REDIS_PORT = toString cfg.redis.port;
      }
      // (lib.mapAttrs (
        name: value:
        if lib.isList value then
          "[" + lib.concatStringsSep ", " (map (x: toString x) value) + "]"
        else if lib.isBool value then
          lib.boolToString value
        else
          toString value
      ) cfg.environment);

      script = ''
        ${lib.optionalString (cfg.redis.passwordFile != null) ''
          export REDIS_PASSWORD="$(cat $CREDENTIALS_DIRECTORY/redis-password)"
        ''}
        ${lib.getExe cfg.package}
      '';

      serviceConfig = {
        AmbientCapabilities = lib.optionalString (cfg.port < 1024) "cap_net_bind_service";
        CapabilityBoundingSet = "";
        DynamicUser = true;
        EnvironmentFile = cfg.environmentFile;

        LoadCredential = lib.optionalString (
          cfg.redis.passwordFile != null
        ) "redis-password:${cfg.redis.passwordFile}";

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "full";
        ReadWritePaths = cfg.dataDir;
        RemoveIPC = true;
        Restart = "always";

        # Hardening
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "send";
        SystemCallArchitectures = "native";
        Type = "simple";
        UMask = "0077";
        WorkingDirectory = cfg.dataDir;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
