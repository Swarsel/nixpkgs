# GNOME Disks.

{
  config,
  lib,
  pkgs,
  ...
}:

{

  ###### interface
  options = {

    programs.gnome-disks = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable GNOME Disks daemon, a program designed to
          be a UDisks2 graphical front-end.
        '';

        type = lib.types.bool;
      };

    };

  };

  ###### implementation
  config = lib.mkIf config.programs.gnome-disks.enable {

    environment.systemPackages = [ pkgs.gnome-disk-utility ];
    services.dbus.packages = [ pkgs.gnome-disk-utility ];

  };

  meta = {
    teams = [ lib.teams.gnome ];
  };

}
