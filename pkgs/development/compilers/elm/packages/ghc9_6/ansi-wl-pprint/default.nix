{
  lib,
  ansi-terminal,
  base,
  fetchgit,
  mkDerivation,
}:
mkDerivation {
  pname = "ansi-wl-pprint";
  version = "0.6.8.1";

  src = fetchgit {
    url = "https://github.com/ekmett/ansi-wl-pprint";
    rev = "d16e2f6896d76b87b72af7220c2e93ba15c53280";
    sha256 = "00pgxgkramz6y1bgdlm00rsh6gd6mdaqllh6riax2rc2sa35kip4";
    fetchSubmodules = true;
  };

  description = "The Wadler/Leijen Pretty Printer for colored ANSI terminal output";
  homepage = "http://github.com/ekmett/ansi-wl-pprint";
  isExecutable = true;
  isLibrary = true;

  libraryHaskellDepends = [
    ansi-terminal
    base
  ];

  license = lib.licenses.bsd3;
}
