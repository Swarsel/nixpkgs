# GPaste.
{
  config,
  lib,
  pkgs,
  ...
}:

{

  ###### interface
  options = {
    programs.gpaste = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable GPaste, a clipboard manager.
        '';

        type = lib.types.bool;
      };
    };
  };

  ###### implementation
  config = lib.mkIf config.programs.gpaste.enable {
    environment.systemPackages = [ pkgs.gpaste ];
    services.dbus.packages = [ pkgs.gpaste ];
    # gnome-control-center crashes in Keyboard Shortcuts pane without the GSettings schemas.
    services.desktopManager.gnome.sessionPath = [ pkgs.gpaste ];
    # gpaste-reloaded applet doesn't work without the typelib
    services.xserver.desktopManager.cinnamon.sessionPath = [ pkgs.gpaste ];
    systemd.packages = [ pkgs.gpaste ];
  };
}
