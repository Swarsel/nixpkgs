{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  rustPlatform,
  rustc,
  setuptools,
}:

buildPythonPackage rec {
  pname = "tree-sitter-make";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "tree-sitter-grammars";
    repo = "tree-sitter-make";
    rev = "v${version}";
    hash = "sha256-WiuhAp9JZKLd0wKCui9MV7AYFOW9dCbUp+kkVl1OEz0=";
  };

  # There are no tests
  doCheck = false;

  build-system = [
    cargo
    rustPlatform.cargoSetupHook
    rustc
    setuptools
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-75jtur5rmG4zpNXSE3OpPVR+/lf4SICsh+kgzIKfbd4=";
  };

  pyproject = true;

  pythonImportsCheck = [
    "tree_sitter_make"
  ];

  meta = {
    description = "Makefile grammar for tree-sitter";
    homepage = "https://github.com/tree-sitter-grammars/tree-sitter-make";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
