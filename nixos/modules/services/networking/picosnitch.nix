{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.picosnitch;
in
{
  options.services.picosnitch = {
    enable = mkEnableOption "picosnitch daemon";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.picosnitch ];

    systemd.services.picosnitch = {
      description = "picosnitch";

      serviceConfig = {
        ExecStart = "${pkgs.picosnitch}/bin/picosnitch start-no-daemon";
        PIDFile = "/run/picosnitch/picosnitch.pid";
        Restart = "always";
        RestartSec = 5;
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
