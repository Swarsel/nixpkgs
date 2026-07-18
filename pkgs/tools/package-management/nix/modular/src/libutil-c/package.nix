{
  lib,
  mkMesonLibrary,

  nix-util,

  # Configuration Options

  version,
}:

mkMesonLibrary (finalAttrs: {
  inherit version;
  pname = "nix-util-c";

  propagatedBuildInputs = [
    nix-util
  ];

  mesonFlags = [
  ];

  workDir = ./.;

  meta = {
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };

})
