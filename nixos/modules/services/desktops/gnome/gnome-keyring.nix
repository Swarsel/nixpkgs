# GNOME Keyring daemon.

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.gnome.gnome-keyring;
in
{

  options = {
    services.gnome.gnome-keyring = {
      enable = lib.mkEnableOption ''
        GNOME Keyring daemon, a service designed to
        take care of the user's security credentials,
        such as user names and passwords
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.gnome-keyring ];
    security.pam.services.login.enableGnomeKeyring = true;

    security.wrappers.gnome-keyring-daemon = {
      capabilities = "cap_ipc_lock=ep";
      group = "root";
      owner = "root";
      source = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon";
    };

    services.dbus.packages = [
      pkgs.gnome-keyring
      pkgs.gcr
    ];

    xdg.portal.extraPortals = [ pkgs.gnome-keyring ];
  };

  meta = {
    teams = [ lib.teams.gnome ];
  };
}
