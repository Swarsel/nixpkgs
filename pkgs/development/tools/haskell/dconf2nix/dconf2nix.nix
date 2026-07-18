{
  lib,
  base,
  containers,
  emojis,
  fetchgit,
  hedgehog,
  mkDerivation,
  optparse-applicative,
  parsec,
  template-haskell,
  text,
}:
mkDerivation {
  pname = "dconf2nix";
  version = "0.1.1";

  src = fetchgit {
    url = "https://github.com/gvolpe/dconf2nix.git";
    rev = "2fc3b0dfbbce9f1ea2ee89f3689a7cb95b33b63f";
    sha256 = "0frqnq7ryr4gvkbb67n0615d9h1blps2kp55ic05n7wxyh26adgz";
    fetchSubmodules = true;
  };

  description = "Convert dconf files to Nix, as expected by Home Manager";
  executableHaskellDepends = [ base ];
  isExecutable = true;
  isLibrary = true;

  libraryHaskellDepends = [
    base
    containers
    emojis
    optparse-applicative
    parsec
    text
  ];

  license = lib.licenses.asl20;
  mainProgram = "dconf2nix";

  testHaskellDepends = [
    base
    containers
    hedgehog
    parsec
    template-haskell
    text
  ];
}
