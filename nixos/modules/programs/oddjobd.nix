{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.oddjobd;
in
{
  options = {
    programs.oddjobd = {
      enable = lib.mkEnableOption "oddjob, a D-Bus service which runs odd jobs on behalf of client applications";
      package = lib.mkPackageOption pkgs "oddjob" { };
    };
  };

  config = lib.mkIf cfg.enable {
    services.dbus.packages = [ cfg.package ];

    systemd.services.oddjobd = {
      enable = true;

      after = [
        "network.target"
        "dbus.service"
      ];

      description = "DBUS Odd-job Daemon";

      documentation = [
        "man:oddjobd(8)"
        "man:oddjobd.conf(5)"
      ];

      serviceConfig = {
        ExecStart = "${lib.getBin cfg.package}/bin/oddjobd -n -p /run/oddjobd.pid -t 300";
        PIDFile = "/run/oddjobd.pid";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ SohamG ];
}
