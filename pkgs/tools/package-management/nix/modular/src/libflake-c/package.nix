{
  lib,
  mkMesonLibrary,
  nix-expr-c,
  nix-fetchers-c,
  nix-flake,
  nix-store-c,
  # Configuration Options
  version,
}:

mkMesonLibrary (finalAttrs: {
  inherit version;
  pname = "nix-flake-c";

  propagatedBuildInputs = [
    nix-expr-c
    nix-store-c
  ]
  ++ lib.optionals (lib.versionAtLeast version "2.29pre") [
    nix-fetchers-c
  ]
  ++ [
    nix-flake
  ];

  mesonFlags = [
  ];

  workDir = ./.;

  meta = {
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };

})
