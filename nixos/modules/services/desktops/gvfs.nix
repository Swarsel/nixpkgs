# GVfs

{
  config,
  lib,
  pkgs,
  ...
}:

let

  cfg = config.services.gvfs;

in

{

  ###### interface
  options = {

    services.gvfs = {

      enable = lib.mkEnableOption "GVfs, a userspace virtual filesystem";
      # gvfs can be built with multiple configurations
      package = lib.mkPackageOption pkgs [ "gnome" "gvfs" ] { };

    };

  };

  ###### implementation
  config = lib.mkIf cfg.enable {

    # Needed for unwrapped applications
    environment.sessionVariables.GIO_EXTRA_MODULES = [ "${cfg.package}/lib/gio/modules" ];
    environment.systemPackages = [ cfg.package ];
    programs.fuse.enable = true;
    services.dbus.packages = [ cfg.package ];
    services.udev.packages = [ pkgs.libmtp.out ];
    services.udisks2.enable = true;
    systemd.packages = [ cfg.package ];

  };

  meta = {
    teams = [ lib.teams.gnome ];
  };

}
