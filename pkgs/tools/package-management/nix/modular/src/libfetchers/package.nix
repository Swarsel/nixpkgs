{
  lib,
  libgit2,
  mkMesonLibrary,
  nix-store,
  nix-util,
  nlohmann_json,
  # Configuration Options
  version,
}:

mkMesonLibrary (finalAttrs: {
  inherit version;
  pname = "nix-fetchers";

  buildInputs = [
    libgit2
  ];

  propagatedBuildInputs = [
    nix-store
    nix-util
    nlohmann_json
  ];

  workDir = ./.;

  meta = {
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };

})
