# GNOME User Share daemon.

{
  config,
  lib,
  pkgs,
  ...
}:

{

  ###### interface
  options = {

    services.gnome.gnome-user-share = {

      enable = lib.mkEnableOption "GNOME User Share, a user-level file sharing service for GNOME";

    };

  };

  ###### implementation
  config = lib.mkIf config.services.gnome.gnome-user-share.enable {

    environment.systemPackages = [
      pkgs.gnome-user-share
    ];

    systemd.packages = [
      pkgs.gnome-user-share
    ];

  };

  meta = {
    teams = [ lib.teams.gnome ];
  };

}
