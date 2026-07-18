# cd nixpkgs
# nix-build -A tests.pkg-config
{
  lib,
  stdenv,
  config,
  ...
}:

let
  # defaultPkgConfigPackages test needs a Nixpkgs with allowUnsupportedPlatform
  # in order to filter out the unsupported packages without throwing any errors
  # tryEval would be too fragile, masking different problems as if they're
  # unsupported platform problems.
  allPkgs = import ../default.nix {
    config = config // {
      allowUnsupportedSystem = true;
    };

    localSystem = stdenv.buildPlatform.system;
    overlays = [ ];
    system = stdenv.hostPlatform.system;
  };
in
lib.recurseIntoAttrs {
  defaultPkgConfigPackages = allPkgs.callPackage ./test-defaultPkgConfigPackages.nix { };
}
