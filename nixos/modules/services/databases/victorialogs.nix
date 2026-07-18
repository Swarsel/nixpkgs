{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  inherit (lib)
    escapeShellArgs
    getBin
    hasPrefix
    literalExpression
    mkBefore
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optionalString
    types
    ;
  cfg = config.services.victorialogs;
  startCLIList = [
    "${cfg.package}/bin/victoria-logs"
    "-storageDataPath=/var/lib/${cfg.stateDir}"
    "-httpListenAddr=${cfg.listenAddress}"
  ]
  ++ lib.optionals (cfg.basicAuthUsername != null) [
    "-httpAuth.username=${cfg.basicAuthUsername}"
  ]
  ++ lib.optionals (cfg.basicAuthPasswordFile != null) [
    "-httpAuth.password=file://%d/basic_auth_password"
  ];
in
{
  options.services.victorialogs = {
    enable = mkEnableOption "VictoriaLogs is an open source user-friendly database for logs from VictoriaMetrics";
    package = mkPackageOption pkgs "victorialogs" { };

    basicAuthPasswordFile = lib.mkOption {
      default = null;

      description = ''
        File that contains the Basic Auth password used to protect VictoriaLogs instance by authorization
      '';

      type = lib.types.nullOr lib.types.str;
    };

    basicAuthUsername = lib.mkOption {
      default = null;

      description = ''
        Basic Auth username used to protect VictoriaLogs instance by authorization
      '';

      type = lib.types.nullOr lib.types.str;
    };

    extraOptions = mkOption {
      default = [ ];

      description = ''
        Extra options to pass to VictoriaLogs. See {command}`victoria-logs -help` for
        possible options.
      '';

      example = literalExpression ''
        [
          "-loggerLevel=WARN"
        ]
      '';

      type = types.listOf types.str;
    };

    listenAddress = mkOption {
      default = ":9428";

      description = ''
        TCP address to listen for incoming http requests.
      '';

      type = types.str;
    };

    stateDir = mkOption {
      default = "victorialogs";

      description = ''
        Directory below `/var/lib` to store VictoriaLogs data.
        This directory will be created automatically using systemd's StateDirectory mechanism.
      '';

      type = types.str;
    };
  };

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion =
          (cfg.basicAuthUsername == null && cfg.basicAuthPasswordFile == null)
          || (cfg.basicAuthUsername != null && cfg.basicAuthPasswordFile != null);

        message = "Both basicAuthUsername and basicAuthPasswordFile must be set together to enable basicAuth functionality, or neither should be set.";
      }
    ];

    systemd.services.victorialogs = {
      after = [ "network.target" ];
      description = "VictoriaLogs logs database";

      postStart =
        let
          bindAddr = (optionalString (hasPrefix ":" cfg.listenAddress) "127.0.0.1") + cfg.listenAddress;
        in
        mkBefore ''
          until ${getBin pkgs.curl}/bin/curl -s -o /dev/null http://${bindAddr}/ping; do
            sleep 1;
          done
        '';

      serviceConfig = {
        # Hardening
        DeviceAllow = [ "/dev/null rw" ];
        DevicePolicy = "strict";
        DynamicUser = true;

        ExecStart = lib.concatStringsSep " " [
          (escapeShellArgs startCLIList)
          (utils.escapeSystemdExecArgs cfg.extraOptions)
        ];

        LoadCredential = lib.optional (
          cfg.basicAuthPasswordFile != null
        ) "basic_auth_password:${cfg.basicAuthPasswordFile}";

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "full";
        RemoveIPC = true;
        Restart = "on-failure";
        RestartSec = 1;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "victorialogs";
        RuntimeDirectoryMode = "0700";
        StateDirectory = cfg.stateDir;
        StateDirectoryMode = "0700";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "mincore"
        ];
      };

      startLimitBurst = 5;
      wantedBy = [ "multi-user.target" ];
    };
  };
}
