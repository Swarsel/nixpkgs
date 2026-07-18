# This module defines a NixOS configuration with the Plasma 6 desktop.
# It's used by the graphical installation CD.

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.mesa-demos
    pkgs.firefox
  ];

  services = {
    displayManager.plasma-login-manager.enable = true;
    libinput.enable = true; # for touchpad support on many laptops
  };

  services.xserver = {
    enable = true;
    desktopManager.plasma6.enable = true;
  };
}
