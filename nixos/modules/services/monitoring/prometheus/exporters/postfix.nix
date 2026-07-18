{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.prometheus.exporters.postfix;
  inherit (lib)
    mkOption
    types
    mkIf
    escapeShellArg
    concatStringsSep
    optional
    ;
in
{
  extraOpts = {
    package = lib.mkPackageOption pkgs "prometheus-postfix-exporter" { };

    group = mkOption {
      description = ''
        Group under which the postfix exporter shall be run.
        It should match the group that is allowed to access the
        `showq` socket in the `queue/public/` directory.
        Defaults to `services.postfix.setgidGroup` when postfix is enabled.
      '';

      type = types.str;
    };

    logfilePath = mkOption {
      default = "/var/log/postfix_exporter_input.log";

      description = ''
        Path where Postfix writes log entries.
        This file will be truncated by this exporter!
      '';

      example = "/var/log/mail.log";
      type = types.path;
    };

    showqPath = mkOption {
      default = "/var/lib/postfix/queue/public/showq";

      description = ''
        Path where Postfix places its showq socket.
      '';

      example = "/var/spool/postfix/public/showq";
      type = types.path;
    };

    systemd = {
      enable = mkOption {
        default = true;

        description = ''
          Whether to enable reading metrics from the systemd journal instead of from a logfile
        '';

        type = types.bool;
      };

      journalPath = mkOption {
        default = null;

        description = ''
          Path to the systemd journal.
        '';

        type = types.nullOr types.path;
      };

      slice = mkOption {
        default = null;

        description = ''
          Name of the postfix systemd slice.
          This overrides the {option}`systemd.unit`.
        '';

        type = types.nullOr types.str;
      };

      unit = mkOption {
        default = "postfix.service";

        description = ''
          Name of the postfix systemd unit.
        '';

        type = types.str;
      };
    };

    telemetryPath = mkOption {
      default = "/metrics";

      description = ''
        Path under which to expose metrics.
      '';

      type = types.str;
    };
  };

  port = 9154;

  serviceOpts = {
    after = mkIf cfg.systemd.enable [ cfg.systemd.unit ];

    serviceConfig = {
      DynamicUser = false;

      ExecStart = ''
        ${lib.getExe cfg.package} \
          --web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
          --web.telemetry-path ${cfg.telemetryPath} \
          --postfix.showq_path ${escapeShellArg cfg.showqPath} \
          ${concatStringsSep " \\\n  " (
            cfg.extraFlags
            ++ optional cfg.systemd.enable "--systemd.enable"
            ++ optional cfg.systemd.enable (
              if cfg.systemd.slice != null then
                "--systemd.slice ${cfg.systemd.slice}"
              else
                "--systemd.unit ${cfg.systemd.unit}"
            )
            ++ optional (
              cfg.systemd.enable && (cfg.systemd.journalPath != null)
            ) "--systemd.journal_path ${escapeShellArg cfg.systemd.journalPath}"
            ++ optional (!cfg.systemd.enable) "--postfix.logfile_path ${escapeShellArg cfg.logfilePath}"
          )}
      '';

      # By default, each prometheus exporter only gets AF_INET & AF_INET6,
      # but AF_UNIX is needed to read from the `showq`-socket.
      RestrictAddressFamilies = [ "AF_UNIX" ];
      SupplementaryGroups = mkIf cfg.systemd.enable [ "systemd-journal" ];
    };
  };
}
