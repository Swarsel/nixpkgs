{ lib, ... }:

with lib;

{
  boot.loader.grub.device = mkOverride 0 "nodev";
  isSpecialisation = mkOverride 0 true;
  specialisation = mkOverride 0 { };
}
