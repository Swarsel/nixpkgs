{
  lib,
  aeson,
  avh4-lib,
  base,
  bimap,
  binary,
  bytestring,
  containers,
  elm-format-markdown,
  elm-format-test-lib,
  fetchgit,
  hspec,
  mkDerivation,
  mtl,
  optparse-applicative,
  relude,
  split,
  tasty,
  tasty-discover,
  tasty-hspec,
  tasty-hunit,
  text,
}:
mkDerivation {
  pname = "elm-format-lib";
  version = "0.0.0.1";

  src = fetchgit {
    url = "https://github.com/avh4/elm-format";
    rev = "d07fddc8c0eef412dba07be4ab8768d6abcca796";
    sha256 = "13i1wgva6p9zsx1a7sfb3skc0rv187isb920chkhljyh48c12k8l";
    fetchSubmodules = true;
  };

  description = "Common code used by elm-format and elm-refactor";
  doHaddock = false;

  libraryHaskellDepends = [
    aeson
    avh4-lib
    base
    bimap
    binary
    bytestring
    containers
    elm-format-markdown
    mtl
    optparse-applicative
    relude
    text
  ];

  license = lib.licenses.bsd3;
  postUnpack = "sourceRoot+=/elm-format-lib; echo source root reset to $sourceRoot";

  testHaskellDepends = [
    aeson
    avh4-lib
    base
    bimap
    binary
    bytestring
    containers
    elm-format-markdown
    elm-format-test-lib
    hspec
    mtl
    optparse-applicative
    relude
    split
    tasty
    tasty-hspec
    tasty-hunit
    text
  ];

  testToolDepends = [ tasty-discover ];
}
