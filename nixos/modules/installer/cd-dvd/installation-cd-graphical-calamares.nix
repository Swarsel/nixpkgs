# This module adds the calamares installer to the basic graphical NixOS
# installation CD.

{ pkgs, ... }:
let
  calamares-nixos-autostart = pkgs.makeAutostartItem {
    package = pkgs.calamares-nixos;
    name = "calamares";
  };
in
{
  imports = [ ./installation-cd-graphical-base.nix ];

  environment.systemPackages = with pkgs; [
    # Calamares for graphical installation
    calamares-nixos
    calamares-nixos-autostart
    calamares-nixos-extensions
    # Get list of locales
    glibcLocales
  ];

  # Support choosing from any locale
  i18n.supportedLocales = [ "all" ];
  # required for kpmcore to work correctly
  programs.partition-manager.enable = true;
  # required for calamares
  security.polkit.enablePkexecWrapper = true;
}
