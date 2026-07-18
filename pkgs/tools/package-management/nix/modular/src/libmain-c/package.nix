{
  lib,
  mkMesonLibrary,
  nix-main,
  nix-store,
  nix-store-c,
  nix-util-c,
  # Configuration Options
  version,
}:

mkMesonLibrary (finalAttrs: {
  inherit version;
  pname = "nix-main-c";

  propagatedBuildInputs = [
    nix-util-c
    nix-store
    nix-store-c
    nix-main
  ];

  mesonFlags = [
  ];

  workDir = ./.;

  meta = {
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };

})
