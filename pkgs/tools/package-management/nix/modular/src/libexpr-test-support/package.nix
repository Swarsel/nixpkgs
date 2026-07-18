{
  lib,
  mkMesonLibrary,
  nix-expr,
  nix-expr-c,
  nix-store-test-support,
  rapidcheck,
  # Configuration Options
  version,
}:

mkMesonLibrary (finalAttrs: {
  inherit version;
  pname = "nix-util-test-support";

  propagatedBuildInputs = [
    nix-store-test-support
    nix-expr
    nix-expr-c
    rapidcheck
  ];

  mesonFlags = [
  ];

  workDir = ./.;

  meta = {
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };

})
