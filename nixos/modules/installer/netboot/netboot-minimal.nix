# This module defines a small netboot environment.

{ lib, ... }:

{
  imports = [
    ./netboot-base.nix
    ../../profiles/minimal.nix
  ];

  documentation.man.enable = lib.mkOverride 500 true;
  hardware.enableRedistributableFirmware = lib.mkOverride 70 false;
  networking.networkmanager.enable = lib.mkOverride 500 false;
  system.extraDependencies = lib.mkOverride 70 [ ];
}
