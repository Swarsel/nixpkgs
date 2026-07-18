{
  lib,
  mkMesonLibrary,
  nix-expr,
  nix-store-c,
  # Configuration Options
  version,
}:

mkMesonLibrary (finalAttrs: {
  inherit version;
  pname = "nix-expr-c";

  propagatedBuildInputs = [
    nix-store-c
    nix-expr
  ];

  mesonFlags = [
  ];

  workDir = ./.;

  meta = {
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };

})
