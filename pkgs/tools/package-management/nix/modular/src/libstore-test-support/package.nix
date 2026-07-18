{
  lib,
  gtest,
  mkMesonLibrary,
  nix-store,
  nix-store-c,
  nix-util-test-support,
  rapidcheck,
  # Configuration Options
  version,
}:

mkMesonLibrary (finalAttrs: {
  inherit version;
  pname = "nix-store-test-support";

  propagatedBuildInputs = [
    nix-util-test-support
    nix-store
    nix-store-c
    rapidcheck
  ]
  ++ lib.optional (lib.versionAtLeast version "2.34pre") gtest;

  mesonFlags = [
  ];

  workDir = ./.;

  meta = {
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };

})
