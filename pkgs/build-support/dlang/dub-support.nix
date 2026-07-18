{ lib, callPackage }:

{
  buildDubPackage = callPackage ./builddubpackage { };
  dub-to-nix = callPackage ./dub-to-nix { };
  importDubLock = callPackage ./builddubpackage/import-dub-lock.nix { };
}
// import ./builddubpackage/hooks { inherit lib callPackage; }
