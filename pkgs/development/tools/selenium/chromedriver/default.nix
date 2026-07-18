{
  lib,
  stdenv,
  callPackage,
  chromium,
}:
if lib.meta.availableOn stdenv.hostPlatform chromium then
  callPackage ./source.nix { }
else
  callPackage ./binary.nix { }
