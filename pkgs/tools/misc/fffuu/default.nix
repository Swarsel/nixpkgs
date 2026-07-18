{
  lib,
  fetchFromGitHub,
  haskellPackages,
  mkDerivation,
}:

mkDerivation {
  pname = "fffuu";
  version = "unstable-2018-05-26";

  src = fetchFromGitHub {
    owner = "diekmann";
    repo = "Iptables_Semantics";
    rev = "e0a2516bd885708fce875023b474ae341cbdee29";
    sha256 = "1qc7p44dqja6qrjbjdc2xn7n9v41j5v59sgjnxjj5k0mxp58y1ch";
  };

  postPatch = ''
    substituteInPlace fffuu.cabal \
      --replace "containers >=0.5 && <0.6" "containers >= 0.6" \
      --replace "optparse-generic >= 1.2.3 && < 1.3" "optparse-generic >= 1.2.3" \
      --replace "split >= 0.2.3 && <= 0.2.4" "split >= 0.2.3"
  '';

  # fails with sandbox
  doCheck = false;
  description = "Fancy Formal Firewall Universal Understander";
  executableHaskellDepends = with haskellPackages; [ base ];
  homepage = "https://github.com/diekmann/Iptables_Semantics/tree/master/haskell_tool";
  isExecutable = true;
  isLibrary = false;

  libraryHaskellDepends = with haskellPackages; [
    base
    containers
    split
    parsec
    optparse-generic
  ];

  license = lib.licenses.bsd2;
  maintainers = [ ];

  postUnpack = ''
    sourceRoot="$sourceRoot/haskell_tool"
  '';

  testHaskellDepends = with haskellPackages; [
    tasty
    tasty-hunit
    tasty-golden
  ];
}
