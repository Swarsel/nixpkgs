{
  lib,
  fetchFromGitHub,
  haskell,
}:

let
  # Remove when haskellPackages is on GHC 9.12
  haskellPackages = haskell.packages.ghc912;
in

haskellPackages.mkDerivation {
  pname = "hooky";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "brandonchinn178";
    repo = "hooky";
    rev = "281ec8b52f92bdbdad567d673cd5bb581dc6991b";
    hash = "sha256-Salq9DuFc+V88tRhLN62GGKIhCCSznUsnr3TD5ivN/I=";
  };

  doCheck = false;
  description = "A minimal git hooks manager.";

  executableHaskellDepends = with haskellPackages; [
    base
    containers
    directory
    filepath
    optparse-applicative
    process
    text
    unliftio
  ];

  homepage = "https://github.com/brandonchinn178/hooky";
  isExecutable = true;
  isLibrary = true;

  libraryHaskellDepends = with haskellPackages; [
    base
    ansi-terminal
    bytestring
    concurrent-output
    containers
    directory
    filepath
    kdl-hs
    process
    scientific
    text
    time
    unliftio
  ];

  license = lib.licenses.bsd3;
  mainProgram = "hooky";
  maintainers = with lib.maintainers; [ brandonchinn178 ];

  testHaskellDepends = with haskellPackages; [
    base
    directory
    filepath
    process
    skeletest
    temporary
    text
    unliftio
  ];
}
