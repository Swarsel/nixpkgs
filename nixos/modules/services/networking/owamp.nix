{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.owamp;
in
{

  ###### interface

  options = {
    services.owamp.enable = mkEnableOption "OWAMP server";
  };

  ###### implementation

  config = mkIf cfg.enable {
    systemd.services.owamp = {
      description = "Owamp server";

      serviceConfig = {
        AmbientCapabilities = "cap_net_bind_service";
        ExecStart = "${pkgs.owamp}/bin/owampd -R /run/owamp -d /run/owamp -v -Z ";
        Group = "owamp";
        PrivateTmp = true;
        Restart = "always";
        RuntimeDirectory = "owamp";
        StateDirectory = "owamp";
        Type = "simple";
        User = "owamp";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.owamp = { };

    users.users.owamp = {
      description = "Owamp daemon";
      group = "owamp";
      isSystemUser = true;
    };
  };
}
