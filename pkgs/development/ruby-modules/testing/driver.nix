/*
  Run with:
  nix-build -E 'with import <nixpkgs> { }; callPackage ./test.nix {}' --show-trace; and cat result

  Confusingly, the ideal result ends with something like:
  error: build of ‘/nix/store/3245f3dcl2wxjs4rci7n069zjlz8qg85-test-results.tap.drv’ failed
*/
{
  lib,
  callPackage,
  ruby,
  testFiles,
  writeText,
}@defs:
let
  testTools = rec {
    should = import ./assertions.nix { inherit test lib; };
    stubs = import ./stubs.nix defs;
    test = import ./testing.nix;
  };

  tap = import ./tap-support.nix;

  results = builtins.concatLists (map (file: callPackage file testTools) testFiles);
in
writeText "test-results.tap" (tap.output results)
