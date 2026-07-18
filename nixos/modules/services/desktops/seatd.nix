{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.seatd;
  inherit (lib) mkEnableOption mkOption types;
in
{
  options.services.seatd = {
    enable = mkEnableOption "seatd";

    group = mkOption {
      default = "seat";
      description = "Group to own the seatd socket";
      type = types.str;
    };

    logLevel = mkOption {
      default = "info";
      description = "Logging verbosity";

      type = types.enum [
        "debug"
        "info"
        "error"
        "silent"
      ];
    };

    user = mkOption {
      default = "root";
      description = "User to own the seatd socket";
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      seatd
      sdnotify-wrapper
    ];

    systemd.services.seatd = {
      description = "Seat management daemon";
      documentation = [ "man:seatd(1)" ];
      restartIfChanged = false;

      serviceConfig = {
        ExecStart = "${pkgs.sdnotify-wrapper}/bin/sdnotify-wrapper ${pkgs.seatd.bin}/bin/seatd -n 1 -u ${cfg.user} -g ${cfg.group} -l ${cfg.logLevel}";
        NotifyAccess = "all";
        Restart = "always";
        RestartSec = 1;
        SyslogIdentifier = "seatd";
        Type = "notify";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.seat = lib.mkIf (cfg.group == "seat") { };
  };

  meta.maintainers = with lib.maintainers; [ sinanmohd ];
}
