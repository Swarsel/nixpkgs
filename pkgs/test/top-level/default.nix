{ lib, pkgs, ... }:
let
  nixpkgsFun = import ../../top-level;
in
lib.recurseIntoAttrs {
  # appendOverlays must preserve splicing so that cross-compilation
  # works in NixOS modules (which go through appendOverlays via nixpkgs.nix).
  appendOverlaysPreservesSplicing =
    let
      cross = nixpkgsFun {
        crossSystem = {
          system = "aarch64-linux";
        };

        localSystem = {
          system = "x86_64-linux";
        };
      };
      appended = cross.appendOverlays [ ];
    in
    assert cross.makeWrapper ? __spliced;
    assert appended.makeWrapper ? __spliced;
    pkgs.emptyFile;

  massRebuildVariantComposition =
    let
      variants = [
        "pkgsChecked"
        "pkgsParallel"
        "pkgsStrict"
        "pkgsStructured"
      ];
      all = lib.getAttrFromPath variants pkgs;
      all-reversed = lib.getAttrFromPath (lib.reverseList variants) pkgs;
    in
    assert pkgs.config.allowVariants -> (all.hello == all-reversed.hello);
    pkgs.emptyFile;

  platformEquality =
    let
      configsLocal = [
        # crossSystem is implicitly set to localSystem.
        {
          localSystem = {
            system = "x86_64-linux";
          };
        }
        {
          crossSystem = null;

          localSystem = {
            system = "aarch64-linux";
          };
        }
        # Both systems explicitly set to the same string.
        {
          crossSystem = {
            system = "x86_64-linux";
          };

          localSystem = {
            system = "x86_64-linux";
          };
        }
        # Vendor and ABI inferred from system double.
        {
          crossSystem = {
            config = "aarch64-unknown-linux-gnu";
          };

          localSystem = {
            system = "aarch64-linux";
          };
        }
      ];
      configsCross = [
        # GNU is inferred from double, but config explicitly requests musl.
        {
          crossSystem = {
            config = "aarch64-unknown-linux-musl";
          };

          localSystem = {
            system = "aarch64-linux";
          };
        }
        # Cross-compile from AArch64 to x86-64.
        {
          crossSystem = {
            system = "x86_64-unknown-linux-gnu";
          };

          localSystem = {
            system = "aarch64-linux";
          };
        }
      ];

      pkgsLocal = map nixpkgsFun configsLocal;
      pkgsCross = map nixpkgsFun configsCross;
    in
    assert lib.all (p: p.stdenv.buildPlatform == p.stdenv.hostPlatform) pkgsLocal;
    assert lib.all (p: p.stdenv.buildPlatform != p.stdenv.hostPlatform) pkgsCross;
    pkgs.emptyFile;
}
