{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  tree-sitter,
}:

buildPythonPackage rec {
  pname = "tree-sitter-html";
  version = "0.23.2";

  src = fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-html";
    tag = "v${version}";
    hash = "sha256-Pd5Me1twLGOrRB3pSMVX9M8VKenTK0896aoLznjNkGo=";
  };

  # There are no tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  optional-dependencies = {
    core = [
      tree-sitter
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "tree_sitter_html" ];

  meta = {
    description = "HTML grammar for tree-sitter";
    homepage = "https://github.com/tree-sitter/tree-sitter-html";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
