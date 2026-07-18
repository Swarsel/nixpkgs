{
  lib,
  aeson,
  base,
  filepath,
  mkDerivation,
  optparse-applicative,
  sandwich,
  text,
  unliftio,
  yaml,
}:
mkDerivation {
  pname = "julia-top-n";
  version = "0.1.0.0";

  src = lib.fileset.toSource {
    fileset = lib.fileset.unions [
      ./app
      ./julia-top-n.cabal
      ./package.yaml
      ./stack.yaml
      ./stack.yaml.lock
    ];

    root = ./.;
  };

  executableHaskellDepends = [
    aeson
    base
    filepath
    optparse-applicative
    sandwich
    text
    unliftio
    yaml
  ];

  isExecutable = true;
  isLibrary = false;
  license = lib.licenses.bsd3;
  mainProgram = "julia-top-n-exe";
}
