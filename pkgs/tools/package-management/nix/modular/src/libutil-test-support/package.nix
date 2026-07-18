{
  lib,
  mkMesonLibrary,

  nix-util,
  nix-util-c,

  rapidcheck,

  # Configuration Options

  version,
}:

mkMesonLibrary (finalAttrs: {
  inherit version;
  pname = "nix-util-test-support";

  propagatedBuildInputs = [
    nix-util
    nix-util-c
    rapidcheck
  ];

  mesonFlags = [
  ];

  workDir = ./.;

  meta = {
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };

})
