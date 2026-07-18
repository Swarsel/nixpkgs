{
  lib,
  fetchFromGitHub,
  haskellPackages,
}:

haskellPackages.mkDerivation rec {
  pname = "nota";
  version = "1.0-unstable-2023-03-01";

  src = fetchFromGitHub {
    owner = "pouyakary";
    repo = "Nota";
    rev = "3548b864e5aa30ffbf1704a79dbb3bd3aab813be";
    hash = "sha256-96T9uxUEV22/vn6aoInG1UPXbzlDHswOSkywkdwsMeY=";
  };

  description = "Command line calculator";
  homepage = "https://pouyakary.org/nota/";
  isExecutable = true;
  isLibrary = false;

  libraryHaskellDepends = with haskellPackages; [
    base
    bytestring
    array
    split
    scientific
    parsec
    ansi-terminal
    regex-compat
    containers
    terminal-size
    numbers
    text
    time
  ];

  license = lib.licenses.mpl20;
  mainProgram = "nota";
  maintainers = [ ];
  sourceRoot = "${src.name}/source";
}
