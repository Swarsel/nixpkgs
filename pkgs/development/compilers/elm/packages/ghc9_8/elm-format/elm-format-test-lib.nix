{
  lib,
  avh4-lib,
  base,
  containers,
  fetchgit,
  filepath,
  hspec,
  hspec-core,
  hspec-golden,
  mkDerivation,
  mtl,
  split,
  tasty,
  tasty-discover,
  tasty-hspec,
  tasty-hunit,
  text,
}:
mkDerivation {
  pname = "elm-format-test-lib";
  version = "0.0.0.1";

  src = fetchgit {
    url = "https://github.com/avh4/elm-format";
    rev = "d07fddc8c0eef412dba07be4ab8768d6abcca796";
    sha256 = "13i1wgva6p9zsx1a7sfb3skc0rv187isb920chkhljyh48c12k8l";
    fetchSubmodules = true;
  };

  description = "Test helpers used by elm-format-tests and elm-refactor-tests";
  doHaddock = false;

  libraryHaskellDepends = [
    avh4-lib
    base
    containers
    filepath
    hspec
    hspec-core
    hspec-golden
    mtl
    split
    tasty-hunit
    text
  ];

  license = lib.licenses.bsd3;
  postUnpack = "sourceRoot+=/elm-format-test-lib; echo source root reset to $sourceRoot";

  testHaskellDepends = [
    avh4-lib
    base
    containers
    filepath
    hspec
    hspec-core
    hspec-golden
    mtl
    split
    tasty
    tasty-hspec
    tasty-hunit
    text
  ];

  testToolDepends = [ tasty-discover ];
}
