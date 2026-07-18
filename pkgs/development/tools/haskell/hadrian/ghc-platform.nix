{
  lib,
  base,
  # GHC source tree to build ghc-toolchain from
  ghcSrc,
  ghcVersion,
  mkDerivation,
}:
mkDerivation {
  pname = "ghc-platform";
  version = ghcVersion;
  src = ghcSrc;
  description = "Platform information used by GHC and friends";
  libraryHaskellDepends = [ base ];
  license = lib.licenses.bsd3;

  postUnpack = ''
    sourceRoot="$sourceRoot/libraries/ghc-platform"
  '';
}
