# GLib Networking

{
  config,
  lib,
  pkgs,
  ...
}:

{

  ###### interface
  options = {

    services.gnome.glib-networking = {

      enable = lib.mkEnableOption "network extensions for GLib";

    };

  };

  ###### implementation
  config = lib.mkIf config.services.gnome.glib-networking.enable {

    environment.sessionVariables.GIO_EXTRA_MODULES = [ "${pkgs.glib-networking.out}/lib/gio/modules" ];
    services.dbus.packages = [ pkgs.glib-networking ];
    systemd.packages = [ pkgs.glib-networking ];

  };

  meta = {
    teams = [ lib.teams.gnome ];
  };

}
