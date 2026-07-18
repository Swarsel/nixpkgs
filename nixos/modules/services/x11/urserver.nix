# urserver service
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.urserver;
in
{

  options.services.urserver.enable = lib.mkEnableOption "urserver";

  config = lib.mkIf cfg.enable {

    networking.firewall = {
      allowedTCPPorts = [
        9510
        9512
      ];

      allowedUDPPorts = [
        9511
        9512
      ];
    };

    systemd.user.services.urserver = {
      after = [ "network.target" ];

      description = ''
        Server for Unified Remote: The one-and-only remote for your computer.
      '';

      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart = ''
          ${pkgs.urserver}/bin/urserver --daemon
        '';

        ExecStop = ''
          ${pkgs.procps}/bin/pkill urserver
        '';

        Restart = "on-failure";
        RestartSec = 3;
        Type = "forking";
      };

      wantedBy = [ "graphical-session.target" ];
    };
  };

}
