{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.tzupdate;
in
{
  options.services.tzupdate = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Enable the tzupdate timezone updating service. This provides
        a one-shot service which can be activated with systemctl to
        update the timezone.
      '';

      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs "tzupdate" { };

    timer.enable = lib.mkOption {
      default = true;

      description = ''
        Enable the tzupdate timer to update the timezone automatically.
      '';

      type = lib.types.bool;
    };

    timer.interval = lib.mkOption {
      default = "hourly";

      description = ''
        The interval at which the tzupdate timer should run. See
        {manpage}`systemd.time(7)` to understand the format.
      '';

      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    # We provide a one-shot service that runs at startup once network
    # interfaces are up, but we can’t ensure we actually have Internet access
    # at that point. It can also be run manually with `systemctl start tzupdate`.
    systemd.services.tzupdate = {
      after = [ "network-online.target" ];
      description = "tzupdate timezone update service";

      script = ''
        timezone="$(${lib.getExe cfg.package} --print-only)"
        if [[ -n "$timezone" ]]; then
          echo "Setting timezone to '$timezone'"
          timedatectl set-timezone "$timezone"
        fi
      '';

      serviceConfig = {
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    systemd.timers.tzupdate = {
      enable = cfg.timer.enable;

      timerConfig = {
        OnCalendar = cfg.timer.interval;
        OnStartupSec = "30s";
        Persistent = true;
      };

      wantedBy = [ "timers.target" ];
    };

    # We need to have imperative time zone management for this to work.
    # This will give users an error if they have set an explicit time
    # zone, which is better than silently overriding it.
    time.timeZone = null;
  };

  meta.maintainers = with lib.maintainers; [ doronbehar ];
}
