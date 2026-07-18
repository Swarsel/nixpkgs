# GNOME Online Accounts daemon.

{
  config,
  lib,
  pkgs,
  ...
}:

{

  ###### interface
  options = {

    services.gnome.gnome-online-accounts = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable GNOME Online Accounts daemon, a service that provides
          a single sign-on framework for the GNOME desktop.
        '';

        type = lib.types.bool;
      };

    };

  };

  ###### implementation
  config = lib.mkIf config.services.gnome.gnome-online-accounts.enable {

    environment.systemPackages = [ pkgs.gnome-online-accounts ];
    services.dbus.packages = [ pkgs.gnome-online-accounts ];

  };

  meta = {
    teams = [ lib.teams.gnome ];
  };

}
