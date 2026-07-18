{
  lib,
  mkMesonLibrary,
  nix-cmd,
  nix-expr-c,
  nix-store-c,
  nix-util-c,
  # Configuration Options
  version,
}:

mkMesonLibrary (finalAttrs: {
  inherit version;
  pname = "nix-cmd-c";

  propagatedBuildInputs = [
    nix-util-c
    nix-store-c
    nix-expr-c
    nix-cmd
  ];

  mesonFlags = [ ];
  workDir = ./.;

  meta = {
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };

})
