{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  jinja2,
  jsonschema,
  pygls,
  pytestCheckHook,
  setuptools-generate,
  setuptools-scm,
  tree-sitter,
}:

buildPythonPackage rec {
  pname = "lsp-tree-sitter";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "neomutt";
    repo = "lsp-tree-sitter";
    tag = version;
    hash = "sha256-H5yb33ZsqRtqm1zlnOI0WUfcM2VDKn+qyezmFNtdLGA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools-generate
    setuptools-scm
  ];

  dependencies = [
    colorama
    jinja2
    jsonschema
    pygls
    tree-sitter
  ];

  pyproject = true;
  pythonImportsCheck = [ "lsp_tree_sitter" ];

  meta = {
    description = "Library to create language servers";
    homepage = "https://github.com/neomutt/lsp-tree-sitter";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
