{
  lib,
  breezy,
  stdenvNoCC,
}:
lib.fetchers.withNormalizedHash { } (
  {
    outputHash,
    outputHashAlgo,
    rev,
    url,
  }:

  stdenvNoCC.mkDerivation {
    inherit outputHash outputHashAlgo;
    inherit url rev;
    nativeBuildInputs = [ breezy ];
    builder = ./builder.sh;
    name = "bzr-export";
    outputHashMode = "recursive";
  }
)
