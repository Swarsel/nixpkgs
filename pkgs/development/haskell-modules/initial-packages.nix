args@{
  lib,
  callPackage,
  pkgs,
}:
self: (import ./hackage-packages.nix args self)
