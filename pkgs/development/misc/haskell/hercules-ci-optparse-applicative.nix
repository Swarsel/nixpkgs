{
  lib,
  QuickCheck,
  base,
  fetchgit,
  mkDerivation,
  prettyprinter,
  prettyprinter-ansi-terminal,
  process,
  text,
  transformers,
}:
mkDerivation {
  pname = "hercules-ci-optparse-applicative";
  version = "0.19.0.0";

  src = fetchgit {
    url = "https://github.com/hercules-ci/optparse-applicative.git";
    rev = "b55bb38a2aea0cf776aec707cdce7c7418146077";
    sha256 = "068rsq9j0afrywbcqf6vg4ivfxbb68ab7f0lvg1na81mfn7sfakk";
    fetchSubmodules = true;
  };

  description = "Utilities and combinators for parsing command line options (fork)";
  homepage = "https://github.com/hercules-ci/optparse-applicative";

  libraryHaskellDepends = [
    base
    prettyprinter
    prettyprinter-ansi-terminal
    process
    text
    transformers
  ];

  license = lib.licenses.bsd3;
  maintainers = [ lib.maintainers.roberth ];

  testHaskellDepends = [
    base
    QuickCheck
  ];
}
