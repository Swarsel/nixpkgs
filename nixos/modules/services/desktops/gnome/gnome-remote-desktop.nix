# Remote desktop daemon using Pipewire.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  ###### interface
  options = {
    services.gnome.gnome-remote-desktop = {
      enable = lib.mkEnableOption "Remote Desktop support using Pipewire";
    };
  };

  ###### implementation
  config = lib.mkIf config.services.gnome.gnome-remote-desktop.enable {
    environment.systemPackages = [ pkgs.gnome-remote-desktop ];

    security.polkit = {
      enable = true;
      enablePkexecWrapper = lib.mkDefault true;
    };

    services.dbus.packages = [ pkgs.gnome-remote-desktop ];
    services.pipewire.enable = true;
    systemd.packages = [ pkgs.gnome-remote-desktop ];
    systemd.tmpfiles.packages = [ pkgs.gnome-remote-desktop ];

    # TODO: if possible, switch to using provided g-r-d sysusers.d
    users = {
      groups.gnome-remote-desktop = { };

      users.gnome-remote-desktop = {
        group = "gnome-remote-desktop";
        home = "/var/lib/gnome-remote-desktop";
        isSystemUser = true;
      };
    };
  };

  meta = {
    teams = [ lib.teams.gnome ];
  };
}
