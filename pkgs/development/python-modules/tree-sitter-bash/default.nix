{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  tree-sitter,
}:

buildPythonPackage (finalAttrs: {
  pname = "tree-sitter-bash";
  version = "0.25.1";

  src = fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-bash";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ONQ1Ljk3aRWjElSWD2crCFZraZoRj3b3/VELz1789GE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    tree-sitter
  ];

  build-system = [
    setuptools
  ];

  optional-dependencies = {
    core = [
      tree-sitter
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "tree_sitter_bash" ];

  meta = {
    description = "Bash grammar for tree-sitter";
    homepage = "https://github.com/tree-sitter/tree-sitter-bash";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
