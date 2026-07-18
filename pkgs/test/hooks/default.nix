# To run these tests:
# nix-build -A tests.hooks

{
  lib,
  stdenv,
  tests,
}:

{
  default-stdenv-hooks = lib.recurseIntoAttrs tests.stdenv.hooks;
}
