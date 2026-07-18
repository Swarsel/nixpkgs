{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.touchegg;

in
{
  ###### interface
  options.services.touchegg = {
    enable = mkEnableOption "touchegg, a multi-touch gesture recognizer";
    package = mkPackageOption pkgs "touchegg" { };
  };

  ###### implementation
  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.touchegg = {
      description = "Touchegg Daemon";

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/touchegg --daemon";
        Restart = "on-failure";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    teams = [ teams.pantheon ];
  };
}
