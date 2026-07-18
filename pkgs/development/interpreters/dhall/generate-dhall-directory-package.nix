{
  lib,
  stdenv,
  dhall-nixpkgs,
}:

# This function calls `dhall-to-nixpkgs directory --fixed-output-derivations`
# within a Nix derivation.
#
# This is possible because
# `dhall-to-nixpkgs directory --fixed-output-derivations` will turn remote
# Dhall imports protected with Dhall integrity checksinto fixed-output
# derivations (with the `buildDhallUrl` function), so no unrestricted network
# access is necessary.
lib.makePackageOverridable (
  {
    src,
    # Set to `true` to generate documentation for the package
    document ? false,
    # The file to import, relative to the root directory
    file ? "package.dhall",
  }:
  stdenv.mkDerivation {
    nativeBuildInputs = [ dhall-nixpkgs ];

    buildCommand = ''
      dhall-to-nixpkgs directory --fixed-output-derivations --file "${file}" "${src}" ${lib.optionalString document "--document"} > $out
    '';

    name = "dhall-directory-package.nix";
  }
)
