# This file defines the builds that are run for the `staging` branch.
#
# This should be kept minimal to avoid unnecessary load on Hydra; the
# point is not to duplicate `staging-next`, but to catch basic issues
# early and make bisection less painful.

{
  nixpkgs ? {
    outPath = (import ../../lib).cleanSource ../..;
    revCount = 1234;
    revision = "0000000000000000000000000000000000000000";
    shortRev = "abcdef";
  },
  # Attributes passed to nixpkgs. Don't build packages marked as unfree.
  nixpkgsArgs ? {
    __allowFileset = false;

    config = {
      allowUnfree = false;
      inHydra = true;
    };
  },
  # The platform doubles for which we build Nixpkgs.
  supportedSystems ? builtins.fromJSON (builtins.readFile ./release-supported-systems.json),
}:

let
  release-lib = import ./release-lib.nix {
    inherit supportedSystems nixpkgsArgs;
  };

  inherit (release-lib)
    all
    mapTestOn
    ;
in
mapTestOn {
  stdenv = all;
}
