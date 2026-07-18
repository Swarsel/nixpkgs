{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.i2p;
  homeDir = "/var/lib/i2p";
in
{
  ###### interface
  options.services.i2p.enable = lib.mkEnableOption "I2P router";

  ###### implementation
  config = lib.mkIf cfg.enable {
    systemd.services.i2p = {
      after = [ "network.target" ];
      description = "I2P router with administration interface for hidden services";

      serviceConfig = {
        ExecStart = "${pkgs.i2p}/bin/i2prouter";
        Restart = "on-abort";
        User = "i2p";
        WorkingDirectory = homeDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.i2p.gid = config.ids.gids.i2p;

    users.users.i2p = {
      createHome = true;
      description = "i2p User";
      group = "i2p";
      home = homeDir;
      uid = config.ids.uids.i2p;
    };
  };
}
