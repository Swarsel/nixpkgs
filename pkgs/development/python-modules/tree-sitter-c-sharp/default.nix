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
  pname = "tree-sitter-c-sharp";
  version = "0.23.5";

  src = fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-c-sharp";
    tag = "v${version}";
    hash = "sha256-N5AAlwQFGGi47cj0m7Te08bA486gwY6NBOx4Qcy4lpo=";
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
    hash = "sha256-fPjCguwWE+beoOiLR2EyMtogiv1JRXI8NP4vCuvGHss=";
  };

  optional-dependencies = {
    core = [
      tree-sitter
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "tree_sitter_c_sharp" ];

  meta = {
    description = "C# Grammar for tree-sitter";
    homepage = "https://github.com/tree-sitter/tree-sitter-c-sharp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ yzx9 ];
  };
}
