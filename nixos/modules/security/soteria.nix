{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.security.soteria;
in
{
  options.security.soteria = {
    enable = lib.mkEnableOption null // {
      description = ''
        Whether to enable Soteria, a Polkit authentication agent
        for any desktop environment.

        ::: {.note}
        You should only enable this if you are on a Desktop Environment that
        does not provide a graphical polkit authentication agent, or you are on
        a standalone window manager or Wayland compositor.
        :::
      '';
    };

    package = lib.mkPackageOption pkgs "soteria" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    security.polkit.enable = true;

    systemd.user.services.polkit-soteria = {
      after = [ "graphical-session.target" ];
      description = "Soteria, Polkit authentication agent for any desktop environment";

      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
        Type = "simple";
      };

      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ johnrtitor ];
}
