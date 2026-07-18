{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.victoriametrics;
  settingsFormat = pkgs.formats.yaml { };

  startCLIList = [
    "${cfg.package}/bin/victoria-metrics"
    "-storageDataPath=/var/lib/${cfg.stateDir}"
    "-httpListenAddr=${cfg.listenAddress}"

  ]
  ++ lib.optionals (cfg.retentionPeriod != null) [ "-retentionPeriod=${cfg.retentionPeriod}" ]
  ++ cfg.extraOptions;
  prometheusConfigYml = checkedConfig (
    settingsFormat.generate "prometheusConfig.yaml" cfg.prometheusConfig
  );

  checkedConfig =
    file:
    if cfg.checkConfig then
      pkgs.runCommand "checked-config" { nativeBuildInputs = [ cfg.package ]; } ''
        ln -s ${file} $out
        ${lib.escapeShellArgs startCLIList} -promscrape.config=${file} -dryRun
      ''
    else
      file;
in
{
  options.services.victoriametrics = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Whether to enable VictoriaMetrics in single-node mode.

        VictoriaMetrics is a fast, cost-effective and scalable monitoring solution and time series database.
      '';

      type = lib.types.bool;
    };

    package = mkPackageOption pkgs "victoriametrics" { };

    basicAuthPasswordFile = lib.mkOption {
      default = null;

      description = ''
        File that contains the Basic Auth password used to protect VictoriaMetrics instance by authorization
      '';

      type = lib.types.nullOr lib.types.path;
    };

    basicAuthUsername = lib.mkOption {
      default = null;

      description = ''
        Basic Auth username used to protect VictoriaMetrics instance by authorization
      '';

      type = lib.types.nullOr lib.types.str;
    };

    checkConfig = lib.mkOption {
      default = true;

      description = ''
        Check configuration.

        If you use credentials stored in external files (`environmentFile`, etc),
        they will not be visible  and it will report errors, despite a correct configuration.
      '';

      type = lib.types.bool;
    };

    extraOptions = mkOption {
      default = [ ];

      description = ''
        Extra options to pass to VictoriaMetrics. See the docs:
        <https://docs.victoriametrics.com/single-server-victoriametrics/#list-of-command-line-flags>
        or {command}`victoriametrics -help` for more information.
      '';

      example = literalExpression ''
        [
          "-loggerLevel=WARN"
        ]
      '';

      type = types.listOf types.str;
    };

    listenAddress = mkOption {
      default = ":8428";

      description = ''
        TCP address to listen for incoming http requests.
      '';

      type = types.str;
    };

    prometheusConfig = lib.mkOption {
      default = { };

      description = ''
        Config for prometheus style metrics.
        See the docs: <https://docs.victoriametrics.com/vmagent/#how-to-collect-metrics-in-prometheus-format>
        for more information.
      '';

      example = literalExpression ''
        {
          scrape_configs = [
            {
              job_name = "postgres-exporter";
              metrics_path = "/metrics";
              static_configs = [
                {
                  targets = ["1.2.3.4:9187"];
                  labels.type = "database";
                }
              ];
            }
            {
              job_name = "node-exporter";
              metrics_path = "/metrics";
              static_configs = [
                {
                  targets = ["1.2.3.4:9100"];
                  labels.type = "node";
                }
                {
                  targets = ["5.6.7.8:9100"];
                  labels.type = "node";
                }
              ];
            }
          ];
        }
      '';

      type = lib.types.submodule { freeformType = settingsFormat.type; };
    };

    retentionPeriod = mkOption {
      default = null;

      description = ''
        How long to retain samples in storage.
        The minimum retentionPeriod is 24h or 1d. See also -retentionFilter
        The following optional suffixes are supported: s (second), h (hour), d (day), w (week), y (year).
        If suffix isn't set, then the duration is counted in months (default 1)
      '';

      example = "15d";
      type = types.nullOr types.str;
    };

    stateDir = mkOption {
      default = "victoriametrics";

      description = ''
        Directory below `/var/lib` to store VictoriaMetrics metrics data.
        This directory will be created automatically using systemd's StateDirectory mechanism.
      '';

      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion =
          (cfg.basicAuthUsername == null && cfg.basicAuthPasswordFile == null)
          || (cfg.basicAuthUsername != null && cfg.basicAuthPasswordFile != null);

        message = "Both basicAuthUsername and basicAuthPasswordFile must be set together to enable basicAuth functionality, or neither should be set.";
      }
    ];

    systemd.services.victoriametrics = {
      after = [ "network.target" ];
      description = "VictoriaMetrics time series database";

      postStart =
        let
          bindAddr =
            (lib.optionalString (lib.hasPrefix ":" cfg.listenAddress) "127.0.0.1") + cfg.listenAddress;
        in
        lib.mkBefore ''
          until ${lib.getBin pkgs.curl}/bin/curl -s -o /dev/null http://${bindAddr}/ping; do
            sleep 1;
          done
        '';

      serviceConfig = {
        # Hardening
        DeviceAllow = [ "/dev/null rw" ];
        DevicePolicy = "strict";
        DynamicUser = true;

        ExecStart = lib.escapeShellArgs (
          startCLIList
          ++ lib.optionals (cfg.prometheusConfig != { }) [ "-promscrape.config=${prometheusConfigYml}" ]
          ++ lib.optional (cfg.basicAuthUsername != null) "-httpAuth.username=${cfg.basicAuthUsername}"
          ++ lib.optional (
            cfg.basicAuthPasswordFile != null
          ) "-httpAuth.password=file://%d/basic_auth_password"
        );

        # Increase the limit to avoid errors like 'too many open files'  when merging small parts
        LimitNOFILE = 1048576;

        LoadCredential = lib.optionals (cfg.basicAuthPasswordFile != null) [
          "basic_auth_password:${cfg.basicAuthPasswordFile}"
        ];

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
        RuntimeDirectory = "victoriametrics";
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
