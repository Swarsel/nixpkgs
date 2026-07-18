{
  lib,
  mkMesonLibrary,
  nix-expr,
  nix-fetchers,
  nix-store,
  nix-util,
  nlohmann_json,
  # Configuration Options
  version,
}:

mkMesonLibrary (finalAttrs: {
  inherit version;
  pname = "nix-flake";

  propagatedBuildInputs = [
    nix-store
    nix-util
    nix-fetchers
    nix-expr
    nlohmann_json
  ];

  workDir = ./.;

  meta = {
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };

})
