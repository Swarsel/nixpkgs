{
  config,
  lib,
  pkgs,
  ...
}:

# maintainer: siddharthist

with lib;

let
  cfg = config.services.urxvtd;
in
{
  options.services.urxvtd = {
    enable = mkOption {
      default = false;

      description = ''
        Enable urxvtd, the urxvt terminal daemon. To use urxvtd, run
        "urxvtc".
      '';

      type = types.bool;
    };

    package = mkPackageOption pkgs "rxvt-unicode" { };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    environment.variables.RXVT_SOCKET = "/run/user/$(id -u)/urxvtd-socket";

    systemd.user.services.urxvtd = {
      description = "urxvt terminal daemon";
      partOf = [ "graphical-session.target" ];
      path = [ pkgs.xsel ];

      serviceConfig = {
        Environment = "RXVT_SOCKET=%t/urxvtd-socket";
        ExecStart = "${cfg.package}/bin/urxvtd -o";
        Restart = "on-failure";
        RestartSec = "5s";
      };

      wantedBy = [ "graphical-session.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ rnhmjoj ];

}
