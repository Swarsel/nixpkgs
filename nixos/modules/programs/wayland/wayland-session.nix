{
  lib,
  pkgs,
  enableGtkPortal ? true,
  enableWlrPortal ? true,
  enableXWayland ? true,
}:

{
  programs = {
    dconf.enable = lib.mkDefault true;
    xwayland.enable = lib.mkIf enableXWayland (lib.mkDefault true);
  };

  security = {
    pam.services.swaylock = { };
    polkit.enable = true;
  };

  services.graphical-desktop.enable = true;
  # Window manager only sessions (unlike DEs) don't handle XDG
  # autostart files, so force them to run the service
  services.xserver.desktopManager.runXdgAutostartIfNone = lib.mkDefault true;

  xdg.portal.extraPortals = lib.mkIf enableGtkPortal [
    pkgs.xdg-desktop-portal-gtk
  ];

  xdg.portal.wlr.enable = lib.mkIf enableWlrPortal true;
}
