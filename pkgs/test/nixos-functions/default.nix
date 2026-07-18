/*
  This file is a test that makes sure that the `pkgs.nixos` and
  `pkgs.testers.nixosTest` functions work. It's far from a perfect test suite,
  but better than not checking them at all on hydra.

  To run this test:

      nixpkgs$ nix-build -A tests.nixos-functions
*/
{
  lib,
  stdenv,
  pkgs,
  ...
}:

let
  dummyVersioning = {
    label = "test";
    revision = "test";
    versionSuffix = "test";
  };
in
lib.optionalAttrs (stdenv.hostPlatform.isLinux) (
  lib.recurseIntoAttrs {
    nixos-test =
      (pkgs.nixos {
        boot.loader.grub.enable = false;

        fileSystems."/" = {
          device = "/dev/null";
          fsType = "none";
        };

        system.nixos = dummyVersioning;
        system.stateVersion = lib.trivial.release;
      }).toplevel;
  }
)
