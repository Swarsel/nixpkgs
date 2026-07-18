{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.prometheus.pushgateway;

  cmdlineArgs =
    opt "web.listen-address" cfg.web.listen-address
    ++ opt "web.telemetry-path" cfg.web.telemetry-path
    ++ opt "web.external-url" cfg.web.external-url
    ++ opt "web.route-prefix" cfg.web.route-prefix
    ++ lib.optional cfg.persistMetrics ''--persistence.file="/var/lib/${cfg.stateDir}/metrics"''
    ++ opt "persistence.interval" cfg.persistence.interval
    ++ opt "log.level" cfg.log.level
    ++ opt "log.format" cfg.log.format
    ++ cfg.extraFlags;

  opt = k: v: lib.optional (v != null) ''--${k}="${v}"'';

in
{
  options = {
    services.prometheus.pushgateway = {
      enable = lib.mkEnableOption "Prometheus Pushgateway";
      package = lib.mkPackageOption pkgs "prometheus-pushgateway" { };

      extraFlags = lib.mkOption {
        default = [ ];

        description = ''
          Extra commandline options when launching the Pushgateway.
        '';

        type = lib.types.listOf lib.types.str;
      };

      log.format = lib.mkOption {
        default = null;

        description = ''
          Set the log target and format.

          `null` will default to `logger:stderr`.
        '';

        example = "logger:syslog?appname=bob&local=7";
        type = lib.types.nullOr lib.types.str;
      };

      log.level = lib.mkOption {
        default = null;

        description = ''
          Only log messages with the given severity or above.

          `null` will default to `info`.
        '';

        type = lib.types.nullOr (
          lib.types.enum [
            "debug"
            "info"
            "warn"
            "error"
            "fatal"
          ]
        );
      };

      persistMetrics = lib.mkOption {
        default = false;

        description = ''
          Whether to persist metrics to a file.

          When enabled metrics will be saved to a file called
          `metrics` in the directory
          `/var/lib/pushgateway`. The directory below
          `/var/lib` can be set using
          {option}`services.prometheus.pushgateway.stateDir`.
        '';

        type = lib.types.bool;
      };

      persistence.interval = lib.mkOption {
        default = null;

        description = ''
          The minimum interval at which to write out the persistence file.

          `null` will default to `5m`.
        '';

        example = "10m";
        type = lib.types.nullOr lib.types.str;
      };

      stateDir = lib.mkOption {
        default = "pushgateway";

        description = ''
          Directory below `/var/lib` to store metrics.

          This directory will be created automatically using systemd's
          StateDirectory mechanism when
          {option}`services.prometheus.pushgateway.persistMetrics`
          is enabled.
        '';

        type = lib.types.str;
      };

      web.external-url = lib.mkOption {
        default = null;

        description = ''
          The URL under which Pushgateway is externally reachable.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      web.listen-address = lib.mkOption {
        default = null;

        description = ''
          Address to listen on for the web interface, API and telemetry.

          `null` will default to `:9091`.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      web.route-prefix = lib.mkOption {
        default = null;

        description = ''
          Prefix for the internal routes of web endpoints.

          Defaults to the path of
          {option}`services.prometheus.pushgateway.web.external-url`.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      web.telemetry-path = lib.mkOption {
        default = null;

        description = ''
          Path under which to expose metrics.

          `null` will default to `/metrics`.
        '';

        type = lib.types.nullOr lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !lib.hasPrefix "/" cfg.stateDir;

        message =
          "The option services.prometheus.pushgateway.stateDir"
          + " shouldn't be an absolute directory."
          + " It should be a directory relative to /var/lib.";
      }
    ];

    systemd.services.pushgateway = {
      after = [ "network.target" ];

      serviceConfig = {
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        DynamicUser = true;

        ExecStart =
          "${cfg.package}/bin/pushgateway"
          + lib.optionalString (lib.length cmdlineArgs != 0) (
            " \\\n  " + lib.concatStringsSep " \\\n  " cmdlineArgs
          );

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateIPC = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = "tmpfs";
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        Restart = "always";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = if cfg.persistMetrics then cfg.stateDir else null;

        SystemCallFilter = [
          "@system-service"
          "~@cpu-emulation"
          "~@privileged"
          "~@reboot"
          "~@setuid"
          "~@swap"
        ];
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
