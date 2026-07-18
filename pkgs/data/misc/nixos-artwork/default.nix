{ lib, callPackage }:

{
  wallpapers = lib.recurseIntoAttrs (callPackage ./wallpapers.nix { });
}
