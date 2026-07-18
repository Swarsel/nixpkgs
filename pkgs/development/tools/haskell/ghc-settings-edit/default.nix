{
  lib,
  base,
  containers,
  mkDerivation,
}:

mkDerivation {
  pname = "ghc-settings-edit";
  version = "0.1.0";

  src = builtins.path {
    filter = path: _: (baseNameOf path) != "default.nix";
    name = "source";
    path = ./.;
  };

  description = "Tool for editing GHC's settings file";

  executableHaskellDepends = [
    base
    containers
  ];

  isExecutable = true;
  isLibrary = false;

  license = [
    lib.licenses.mit
    lib.licenses.bsd3
  ];

  mainProgram = "ghc-settings-edit";
}
