{
  lib,
  mkMesonLibrary,
  nix-store,
  nix-util-c,
  # Configuration Options
  version,
}:

mkMesonLibrary (finalAttrs: {
  inherit version;
  pname = "nix-store-c";

  propagatedBuildInputs = [
    nix-util-c
    nix-store
  ];

  mesonFlags = [
  ];

  workDir = ./.;

  meta = {
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };

})
