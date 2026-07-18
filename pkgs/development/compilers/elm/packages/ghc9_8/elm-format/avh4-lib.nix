{
  lib,
  array,
  base,
  bytestring,
  directory,
  fetchgit,
  filepath,
  mkDerivation,
  mtl,
  pooled-io,
  process,
  relude,
  tasty,
  tasty-discover,
  tasty-hunit,
  text,
}:
mkDerivation {
  pname = "avh4-lib";
  version = "0.0.0.1";

  src = fetchgit {
    url = "https://github.com/avh4/elm-format";
    rev = "d07fddc8c0eef412dba07be4ab8768d6abcca796";
    sha256 = "13i1wgva6p9zsx1a7sfb3skc0rv187isb920chkhljyh48c12k8l";
    fetchSubmodules = true;
  };

  description = "Common code for haskell projects";
  doHaddock = false;

  libraryHaskellDepends = [
    array
    base
    bytestring
    directory
    filepath
    mtl
    pooled-io
    process
    relude
    text
  ];

  license = lib.licenses.bsd3;
  postUnpack = "sourceRoot+=/avh4-lib; echo source root reset to $sourceRoot";

  testHaskellDepends = [
    array
    base
    bytestring
    directory
    filepath
    mtl
    pooled-io
    process
    relude
    tasty
    tasty-hunit
    text
  ];

  testToolDepends = [ tasty-discover ];
}
