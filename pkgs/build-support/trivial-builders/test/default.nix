/*
  Run all tests with:

      cd nixpkgs
      nix-build -A tests.trivial-builders

  or run a specific test with:

      cd nixpkgs
      nix-build -A tests.trivial-builders.foo
*/

{
  lib,
  stdenv,
  callPackage,
}:
let
  inherit (lib) recurseIntoAttrs;
  references = callPackage ./references { };
in
recurseIntoAttrs {
  inherit references;
  concat = callPackage ./concat-test.nix { };
  linkFarm = callPackage ./link-farm.nix { };
  overriding = callPackage ../test-overriding.nix { };
  requireFile = callPackage ./requireFile.nix { };
  symlinkJoin = recurseIntoAttrs (callPackage ./symlink-join.nix { });
  writeCBin = callPackage ./writeCBin.nix { };

  writeClosure-union = callPackage ./writeClosure-union.nix {
    inherit (references) samples;
  };

  writeScriptBin = callPackage ./writeScriptBin.nix { };
  writeShellApplication = callPackage ./writeShellApplication.nix { };
  writeShellScript = callPackage ./write-shell-script.nix { };
  writeShellScriptBin = callPackage ./writeShellScriptBin.nix { };

  writeStringReferencesToFile = callPackage ./writeStringReferencesToFile.nix {
    inherit (references) samples;
  };

  writeTextFile = callPackage ./write-text-file.nix { };
}
