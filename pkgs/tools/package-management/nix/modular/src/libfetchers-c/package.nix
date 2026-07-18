{
  lib,
  mkMesonLibrary,
  nix-expr-c,
  nix-fetchers,
  nix-store-c,
  nix-util-c,
  # Configuration Options
  version,
}:

mkMesonLibrary (finalAttrs: {
  inherit version;
  pname = "nix-fetchers-c";

  propagatedBuildInputs = [
    nix-util-c
    nix-expr-c
    nix-store-c
    nix-fetchers
  ];

  mesonFlags = [ ];
  workDir = ./.;

  meta = {
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };

})
