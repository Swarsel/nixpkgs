{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.psd;
in
{
  options.services.psd = with lib.types; {
    enable = lib.mkOption {
      default = false;

      description = ''
        Whether to enable the Profile Sync daemon.
      '';

      type = bool;
    };

    resyncTimer = lib.mkOption {
      default = "1h";

      description = ''
        The amount of time to wait before syncing browser profiles back to the
        disk.

        Takes a systemd.unit time span. The time unit defaults to seconds if
        omitted.
      '';

      example = "1h 30min";
      type = str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      user = {
        services = {
          psd = {
            enable = true;
            description = "Profile Sync daemon";

            path = with pkgs; [
              rsync
              kmod
              gawk
              net-tools
              util-linux
              profile-sync-daemon
            ];

            serviceConfig = {
              ExecStart = "${pkgs.profile-sync-daemon}/bin/profile-sync-daemon sync";
              ExecStop = "${pkgs.profile-sync-daemon}/bin/profile-sync-daemon unsync";
              RemainAfterExit = "yes";
              Type = "oneshot";
            };

            unitConfig = {
              RequiresMountsFor = [ "/home/" ];
            };

            wantedBy = [ "default.target" ];
            wants = [ "psd-resync.service" ];
          };

          psd-resync = {
            enable = true;
            after = [ "psd.service" ];
            description = "Timed profile resync";
            partOf = [ "psd.service" ];

            path = with pkgs; [
              rsync
              kmod
              gawk
              net-tools
              util-linux
              profile-sync-daemon
            ];

            serviceConfig = {
              ExecStart = "${pkgs.profile-sync-daemon}/bin/profile-sync-daemon resync";
              Type = "oneshot";
            };

            wantedBy = [ "default.target" ];
            wants = [ "psd-resync.timer" ];
          };
        };

        timers.psd-resync = {
          description = "Timer for profile sync daemon - ${cfg.resyncTimer}";

          partOf = [
            "psd-resync.service"
            "psd.service"
          ];

          timerConfig = {
            OnUnitActiveSec = "${cfg.resyncTimer}";
          };
        };
      };
    };
  };
}
