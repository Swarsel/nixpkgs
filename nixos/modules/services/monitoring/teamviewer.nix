{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.teamviewer;
in
{
  options = {
    services.teamviewer = {
      enable = lib.mkEnableOption "TeamViewer daemon & system package";
      package = lib.mkPackageOption pkgs "teamviewer" { };
    };
  };

  config = lib.mkIf (cfg.enable) {
    environment.systemPackages = [ cfg.package ];
    services.dbus.packages = [ cfg.package ];

    systemd.services.teamviewerd = {
      after = [
        "network-online.target"
        "network.target"
        "dbus.service"
      ];

      description = "TeamViewer remote control daemon";
      preStart = "mkdir -pv /var/lib/teamviewer /var/log/teamviewer";
      requires = [ "dbus.service" ];

      serviceConfig = {
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = "${cfg.package}/bin/teamviewerd -f";
        PIDFile = "/run/teamviewerd.pid";
        Restart = "on-abort";
        Type = "simple";
      };

      startLimitBurst = 10;
      startLimitIntervalSec = 60;
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };
}
