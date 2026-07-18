{
  lib,
  base,
  directory,
  filepath,
  ghc-platform,
  ghcSrc,
  # GHC source tree to build ghc-toolchain from
  ghcVersion,
  mkDerivation,
  process,
  text,
  transformers,
}:
mkDerivation {
  pname = "ghc-toolchain";
  version = ghcVersion;
  src = ghcSrc;
  description = "Utility for managing GHC target toolchains";

  libraryHaskellDepends = [
    base
    directory
    filepath
    ghc-platform
    process
    text
    transformers
  ];

  license = lib.licenses.bsd3;

  postUnpack = ''
    sourceRoot="$sourceRoot/utils/ghc-toolchain"
  '';
}
