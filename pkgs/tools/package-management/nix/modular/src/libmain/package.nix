{
  lib,
  mkMesonLibrary,
  nix-expr,
  nix-store,
  nix-util,
  openssl,
  # Configuration Options
  version,
}:

mkMesonLibrary (finalAttrs: {
  inherit version;
  pname = "nix-main";

  propagatedBuildInputs =
    lib.optionals (lib.versionAtLeast version "2.28") [
      nix-expr
    ]
    ++ [
      nix-util
      nix-store
      openssl
    ];

  workDir = ./.;

  meta = {
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };

})
