{ lib, pkgs, ... }:

{
  # Remove perl from activation
  boot.initrd.systemd.enable = lib.mkDefault true;
  boot.loader.grub.enable = lib.mkDefault false;
  documentation.info.enable = lib.mkDefault false;
  documentation.nixos.enable = lib.mkDefault false;
  environment.defaultPackages = lib.mkDefault [ ];
  services.userborn.enable = lib.mkDefault true;
  system.etc.overlay.enable = lib.mkDefault true;
  # Check that the system does not contain a Nix store path that contains the
  # string "perl".
  system.forbiddenDependenciesRegexes = [ "perl" ];
  # Random perl remnants
  system.tools.nixos-generate-config.enable = lib.mkDefault false;
}
