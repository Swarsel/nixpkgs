{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.offlineimap;
in
{

  options.services.offlineimap = {
    enable = lib.mkEnableOption "OfflineIMAP, a software to dispose your mailbox(es) as a local Maildir(s)";
    package = lib.mkPackageOption pkgs "offlineimap" { };

    install = lib.mkOption {
      default = false;

      description = ''
        Whether to install a user service for Offlineimap. Once
        the service is started, emails will be fetched automatically.

        The service must be manually started for each user with
        "systemctl --user start offlineimap" or globally through
        {var}`services.offlineimap.enable`.
      '';

      type = lib.types.bool;
    };

    onCalendar = lib.mkOption {
      default = "*:0/3"; # every 3 minutes
      description = "How often is offlineimap started. Default is '*:0/3' meaning every 3 minutes. See {manpage}`systemd.time(7)` for more information about the format.";
      type = lib.types.str;
    };

    path = lib.mkOption {
      default = [ ];
      description = "List of derivations to put in Offlineimap's path.";
      example = lib.literalExpression "[ pkgs.pass pkgs.bash pkgs.notmuch ]";
      type = lib.types.listOf lib.types.path;
    };

    timeoutStartSec = lib.mkOption {
      default = "120sec"; # Kill if still alive after 2 minutes
      description = "How long waiting for offlineimap before killing it. Default is '120sec' meaning every 2 minutes. See {manpage}`systemd.time(7)` for more information about the format.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf (cfg.enable || cfg.install) {
    environment.systemPackages = [ cfg.package ];

    systemd.user.services.offlineimap = {
      description = "Offlineimap: a software to dispose your mailbox(es) as a local Maildir(s)";
      path = cfg.path;

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/offlineimap -u syslog -o -1";
        TimeoutStartSec = cfg.timeoutStartSec;
        Type = "oneshot";
      };
    };

    systemd.user.timers.offlineimap = {
      description = "offlineimap timer";

      timerConfig = {
        OnCalendar = cfg.onCalendar;
        # start immediately after computer is started:
        Persistent = "true";
        Unit = "offlineimap.service";
      };
    }
    // lib.optionalAttrs cfg.enable { wantedBy = [ "default.target" ]; };
  };
}
