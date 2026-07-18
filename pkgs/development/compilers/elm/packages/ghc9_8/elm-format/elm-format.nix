{
  lib,
  QuickCheck,
  aeson,
  ansi-wl-pprint,
  avh4-lib,
  base,
  bytestring,
  elm-format-lib,
  elm-format-test-lib,
  fetchgit,
  hspec,
  mkDerivation,
  optparse-applicative,
  quickcheck-io,
  relude,
  tasty,
  tasty-hspec,
  tasty-hunit,
  tasty-quickcheck,
  text,
}:
mkDerivation {
  pname = "elm-format";
  version = "0.8.8";

  src = fetchgit {
    url = "https://github.com/avh4/elm-format";
    rev = "d07fddc8c0eef412dba07be4ab8768d6abcca796";
    sha256 = "13i1wgva6p9zsx1a7sfb3skc0rv187isb920chkhljyh48c12k8l";
    fetchSubmodules = true;
  };

  description = "A source code formatter for Elm";
  doHaddock = false;

  executableHaskellDepends = [
    aeson
    ansi-wl-pprint
    avh4-lib
    base
    bytestring
    elm-format-lib
    optparse-applicative
    relude
    text
  ];

  homepage = "https://elm-lang.org";
  isExecutable = true;
  isLibrary = false;
  license = lib.licenses.bsd3;
  mainProgram = "elm-format";

  testHaskellDepends = [
    aeson
    ansi-wl-pprint
    avh4-lib
    base
    bytestring
    elm-format-lib
    elm-format-test-lib
    hspec
    optparse-applicative
    QuickCheck
    quickcheck-io
    relude
    tasty
    tasty-hspec
    tasty-hunit
    tasty-quickcheck
    text
  ];
}
