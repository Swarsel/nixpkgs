# nix run ../../../../..#cabal2nix -- ./local
{
  lib,
  base,
  mkDerivation,
}:
mkDerivation {
  pname = "local";
  version = "0.1.0.0";
  src = ./local;
  description = "Nixpkgs test case";
  executableHaskellDepends = [ base ];
  isExecutable = true;
  isLibrary = false;
  license = lib.licenses.mit;
  mainProgram = "local";
}
