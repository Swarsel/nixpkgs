{
  lib,
  haskellPackages,
  mkDerivation,
}:

mkDerivation {
  inherit (haskellPackages.agda2hs) src version;
  pname = "agda2hs-base";
  libraryFile = "base.agda-lib";

  postUnpack = ''
    sourceRoot="$sourceRoot/lib/base"
  '';

  meta = {
    description = "Standard library for compiling Agda code to readable Haskell";
    homepage = "https://github.com/agda/agda2hs";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      wrvsrx
    ];

    platforms = lib.platforms.unix;
  };
}
