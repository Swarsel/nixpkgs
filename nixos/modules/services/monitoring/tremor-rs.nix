{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.tremor-rs;

  loggerSettingsFormat = pkgs.formats.yaml { };
  loggerConfigFile = loggerSettingsFormat.generate "logger.yaml" cfg.loggerSettings;
in
{

  options = {
    services.tremor-rs = {
      enable = lib.mkEnableOption "Tremor event- or stream-processing system";

      host = lib.mkOption {
        default = "127.0.0.1";
        description = "The host tremor should be listening on";
        type = lib.types.str;
      };

      loggerSettings = lib.mkOption {
        default = { };

        defaultText = lib.literalExpression ''
          {
            refresh_rate = "30 seconds";
            appenders.stdout.kind = "console";
            root = {
              level = "warn";
              appenders = [ "stdout" ];
            };
            loggers = {
              tremor_runtime = {
                level = "debug";
                appenders = [ "stdout" ];
                additive = false;
              };
              tremor = {
                level = "debug";
                appenders = [ "stdout" ];
                additive = false;
              };
            };
          }
        '';

        description = "Tremor logger configuration";

        example = {
          appenders.stdout.kind = "console";

          loggers = {
            tremor = {
              additive = false;
              appenders = [ "stdout" ];
              level = "debug";
            };

            tremor_runtime = {
              additive = false;
              appenders = [ "stdout" ];
              level = "debug";
            };
          };

          refresh_rate = "30 seconds";

          root = {
            appenders = [ "stdout" ];
            level = "warn";
          };
        };

        type = loggerSettingsFormat.type;

      };

      port = lib.mkOption {
        default = 9898;
        description = "the port tremor should be listening on";
        type = lib.types.port;
      };

      tremorLibDir = lib.mkOption {
        default = "";
        description = "Directory where to find /lib containing tremor script files";
        type = lib.types.path;
      };

      troyFileList = lib.mkOption {
        default = [ ];
        description = "List of troy files to load.";
        type = lib.types.listOf lib.types.path;
      };
    };
  };

  config = lib.mkIf (cfg.enable) {

    environment.systemPackages = [ pkgs.tremor-rs ];

    systemd.services.tremor-rs = {
      after = [ "network-online.target" ];
      description = "Tremor event- or stream-processing system";
      environment.TREMOR_PATH = "${pkgs.tremor-rs}/lib:${cfg.tremorLibDir}";
      requires = [ "network-online.target" ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkgs.tremor-rs}/bin/tremor --logger-config ${loggerConfigFile} server run ${lib.concatStringsSep " " cfg.troyFileList} --api-host ${cfg.host}:${toString cfg.port}";
        LockPersonality = true;
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
        ProtectProc = "noaccess";
        RemoveIPC = true;
        Restart = "always";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
