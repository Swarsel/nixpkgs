{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  pytestCheckHook,
  rustPlatform,
  rustc,
  setuptools,
  tree-sitter,
}:

buildPythonPackage rec {
  pname = "tree-sitter-embedded-template";
  version = "0.25.0";

  src = fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-embedded-template";
    tag = "v${version}";
    hash = "sha256-nBQain0Lc21jOgQFfvkyq615ZmT8qdMxtqIoUcOcO3A=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    tree-sitter
  ];

  build-system = [
    cargo
    rustPlatform.cargoSetupHook
    rustc
    setuptools
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-C+P/fALEmRDrX59diXS/cdzffvJyn0qnCUD5nFsW+ww=";
  };

  optional-dependencies = {
    core = [
      tree-sitter
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "tree_sitter_embedded_template" ];

  meta = {
    description = "Tree-sitter grammar for embedded template languages like ERB, EJS";
    homepage = "https://github.com/tree-sitter/tree-sitter-embedded-template";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ yzx9 ];
  };
}
