{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.earlyoom;

  inherit (lib)
    literalExpression
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    mkRemovedOptionModule
    optionalString
    optionals
    types
    ;
in
{
  imports = [
    (mkRemovedOptionModule [ "services" "earlyoom" "useKernelOOMKiller" ] ''
      This option is deprecated and ignored by earlyoom since 1.2.
    '')
    (mkRemovedOptionModule [ "services" "earlyoom" "notificationsCommand" ] ''
      This option was removed in earlyoom 1.6, but was reimplemented in 1.7
      and is available as the new option `services.earlyoom.killHook`.
    '')
    (mkRemovedOptionModule [ "services" "earlyoom" "ignoreOOMScoreAdjust" ] ''
      This option is deprecated and ignored by earlyoom since 1.7.
    '')
  ];

  options.services.earlyoom = {
    enable = mkEnableOption "early out of memory killing";
    package = mkPackageOption pkgs "earlyoom" { };

    enableDebugInfo = mkOption {
      default = false;

      description = ''
        Enable debugging messages.
      '';

      type = types.bool;
    };

    enableNotifications = mkOption {
      default = false;

      description = ''
        Send notifications about killed processes via the system d-bus.

        WARNING: enabling this option (while convenient) should *not* be done on a
        machine where you do not trust the other users as it allows any other
        local user to DoS your session by spamming notifications.

        To actually see the notifications in your GUI session, you need to have
        `systembus-notify` running as your user, which this
        option handles by enabling {option}`services.systembus-notify`.

        See [README](https://github.com/rfjakob/earlyoom#notifications) for details.
      '';

      type = types.bool;
    };

    extraArgs = mkOption {
      default = [ ];

      description = ''
        Extra command-line arguments to be passed to earlyoom. Each element in
        the value list will be escaped as an argument without further
        word-breaking.
      '';

      example = [
        "-g"
        "--prefer"
        "(^|/)(java|chromium)$"
      ];

      type = types.listOf types.str;
    };

    freeMemKillThreshold = mkOption {
      default = null;

      description = ''
        Minimum available memory (in percent) before sending SIGKILL.
        If unset, this defaults to half of {option}`freeMemThreshold`.

        See the description of [](#opt-services.earlyoom.freeMemThreshold).
      '';

      type = types.nullOr (types.ints.between 1 100);
    };

    freeMemThreshold = mkOption {
      default = 10;

      description = ''
        Minimum available memory (in percent).

        If the available memory falls below this threshold (and the analog is true for
        {option}`freeSwapThreshold`) the killing begins.
        SIGTERM is sent first to the process that uses the most memory; then, if the available
        memory falls below {option}`freeMemKillThreshold` (and the analog is true for
        {option}`freeSwapKillThreshold`), SIGKILL is sent.

        See [README](https://github.com/rfjakob/earlyoom#command-line-options) for details.
      '';

      type = types.ints.between 1 100;
    };

    freeSwapKillThreshold = mkOption {
      default = null;

      description = ''
        Minimum free swap space (in percent) before sending SIGKILL.
        If unset, this defaults to half of {option}`freeSwapThreshold`.

        See the description of [](#opt-services.earlyoom.freeMemThreshold).
      '';

      type = types.nullOr (types.ints.between 1 100);
    };

    freeSwapThreshold = mkOption {
      default = 10;

      description = ''
        Minimum free swap space (in percent) before sending SIGTERM.

        See the description of [](#opt-services.earlyoom.freeMemThreshold).
      '';

      type = types.ints.between 1 100;
    };

    killHook = mkOption {
      default = null;

      description = ''
        An absolute path to an executable to be run for each process killed.
        Some environment variables are available, see
        [README](https://github.com/rfjakob/earlyoom#notifications) and
        [the man page](https://github.com/rfjakob/earlyoom/blob/master/MANPAGE.md#-n-pathtoscript)
        for details.

        WARNING: earlyoom is running in a sandbox with ProtectSystem="strict"
        by default, so filesystem write is also prohibited for the hook.
        If you want to change these protection rules, override the systemd
        service via `systemd.services.earlyoom.serviceConfig.ProtectSystem`.
      '';

      example = literalExpression ''
        pkgs.writeShellScript "earlyoom-kill-hook" '''
          echo "Process $EARLYOOM_NAME ($EARLYOOM_PID) was killed" >> /path/to/log
        '''
      '';

      type = types.nullOr types.path;
    };

    reportInterval = mkOption {
      default = 3600;
      description = "Interval (in seconds) at which a memory report is printed (set to 0 to disable).";
      example = 0;
      type = types.int;
    };
  };

  config = mkIf cfg.enable {
    services.systembus-notify.enable = mkDefault cfg.enableNotifications;
    systemd.packages = [ cfg.package ];

    systemd.services.earlyoom = {
      environment.EARLYOOM_ARGS =
        lib.cli.toCommandLineShellGNU { } {
          N = if cfg.killHook != null then cfg.killHook else null;
          d = cfg.enableDebugInfo;

          m =
            "${toString cfg.freeMemThreshold}"
            + optionalString (cfg.freeMemKillThreshold != null) ",${toString cfg.freeMemKillThreshold}";

          n = cfg.enableNotifications;
          r = "${toString cfg.reportInterval}";

          s =
            "${toString cfg.freeSwapThreshold}"
            + optionalString (cfg.freeSwapKillThreshold != null) ",${toString cfg.freeSwapKillThreshold}";
        }
        + " "
        + lib.escapeShellArgs cfg.extraArgs;

      overrideStrategy = "asDropin";
      path = optionals cfg.enableNotifications [ pkgs.dbus ];
      # We setup `EARLYOOM_ARGS` via drop-ins, so disable the default import
      # from /etc/default/earlyoom.
      serviceConfig.EnvironmentFile = "";
      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    maintainers = [ ];
  };
}
