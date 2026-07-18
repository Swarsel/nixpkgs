{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.tuptime;

in
{

  options.services.tuptime = {

    enable = lib.mkEnableOption "the total uptime service";

    timer = {
      enable = lib.mkOption {
        default = true;
        description = "Whether to regularly log uptime to detect bad shutdowns.";
        type = lib.types.bool;
      };

      period = lib.mkOption {
        default = "*:0/5";
        description = "systemd calendar event";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkgs.tuptime ];

    systemd = {
      services = {

        tuptime = {
          after = [ "time-sync.target" ];
          description = "The total uptime service";
          documentation = [ "man:tuptime(1)" ];

          serviceConfig = {
            ExecStart = "${pkgs.tuptime}/bin/tuptime -q";
            ExecStop = "${pkgs.tuptime}/bin/tuptime -qg";
            RemainAfterExit = true;
            StateDirectory = "tuptime";
            Type = "oneshot";
            User = "_tuptime";
          };

          wantedBy = [ "multi-user.target" ];
        };

        tuptime-sync = lib.mkIf cfg.timer.enable {
          description = "Tuptime scheduled sync service";

          serviceConfig = {
            ExecStart = "${pkgs.tuptime}/bin/tuptime -q";
            Type = "oneshot";
            User = "_tuptime";
          };
        };
      };

      timers.tuptime-sync = lib.mkIf cfg.timer.enable {
        description = "Tuptime scheduled sync timer";
        # this timer should be stopped if the service is stopped
        partOf = [ "tuptime.service" ];

        timerConfig = {
          OnBootSec = "1min";
          OnCalendar = cfg.timer.period;
          Unit = "tuptime-sync.service";
        };

        # this timer should be started if the service is started
        # even if the timer was previously stopped
        wantedBy = [
          "tuptime.service"
          "timers.target"
        ];
      };
    };

    users = {
      groups._tuptime.members = [ "_tuptime" ];

      users._tuptime = {
        description = "tuptime database owner";
        group = "_tuptime";
        isSystemUser = true;
      };
    };
  };
}
