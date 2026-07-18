{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  tree-sitter,
}:

buildPythonPackage (finalAttrs: {
  pname = "tree-sitter-python";
  version = "0.25.0";

  src = fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-F5XH21PjPpbwYylgKdwD3MZ5o0amDt4xf/e5UikPcxY=";
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
  pythonImportsCheck = [ "tree_sitter_python" ];

  meta = {
    description = "Python grammar for tree-sitter";
    homepage = "https://github.com/tree-sitter/tree-sitter-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
})
