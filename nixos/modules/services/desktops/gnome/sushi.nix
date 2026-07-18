# GNOME Sushi daemon.

{
  config,
  lib,
  pkgs,
  ...
}:

{

  ###### interface
  options = {

    services.gnome.sushi = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable Sushi, a quick previewer for nautilus.
        '';

        type = lib.types.bool;
      };

    };

  };

  ###### implementation
  config = lib.mkIf config.services.gnome.sushi.enable {

    environment.systemPackages = [ pkgs.sushi ];
    services.dbus.packages = [ pkgs.sushi ];

  };

  meta = {
    teams = [ lib.teams.gnome ];
  };

}
