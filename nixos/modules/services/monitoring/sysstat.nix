{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.sysstat;
in
{
  options = {
    services.sysstat = {
      enable = lib.mkEnableOption "sar system activity collection";

      collect-args = lib.mkOption {
        default = "1 1";

        description = ''
          Arguments to pass sa1 when collecting statistics
        '';

        type = lib.types.str;
      };

      collect-frequency = lib.mkOption {
        default = "*:00/10";

        description = ''
          OnCalendar specification for sysstat-collect
        '';

        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.sysstat = {
      description = "Resets System Activity Logs";

      serviceConfig = {
        ExecStart = "${pkgs.sysstat}/lib/sa/sa1 --boot";
        LogsDirectory = "sa";
        RemainAfterExit = true;
        Type = "oneshot";
        User = "root";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.sysstat-collect = {
      description = "system activity accounting tool";

      serviceConfig = {
        ExecStart = "${pkgs.sysstat}/lib/sa/sa1 ${cfg.collect-args}";
        Type = "oneshot";
        User = "root";
      };

      unitConfig.Documentation = "man:sa1(8)";
    };

    systemd.services.sysstat-summary = {
      description = "Generate a daily summary of process accounting";

      serviceConfig = {
        ExecStart = "${pkgs.sysstat}/lib/sa/sa2 -A";
        Type = "oneshot";
        User = "root";
      };

      unitConfig.Documentation = "man:sa2(8)";
    };

    systemd.timers.sysstat-collect = {
      description = "Run system activity accounting tool on a regular basis";
      timerConfig.OnCalendar = cfg.collect-frequency;
      wantedBy = [ "timers.target" ];
    };

    systemd.timers.sysstat-summary = {
      description = "Generate summary of yesterday's process accounting";
      timerConfig.OnCalendar = "00:07:00";
      wantedBy = [ "timers.target" ];
    };
  };
}
