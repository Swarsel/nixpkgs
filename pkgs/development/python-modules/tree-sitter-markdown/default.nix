{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  tree-sitter,
}:

buildPythonPackage rec {
  pname = "tree-sitter-markdown";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "tree-sitter-grammars";
    repo = "tree-sitter-markdown";
    tag = "v${version}";
    hash = "sha256-IYqh6JT74deu1UU4Nyls9Eg88BvQeYEta2UXZAbuZek=";
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
  pythonImportsCheck = [ "tree_sitter_markdown" ];

  meta = {
    description = "Markdown grammar for tree-sitter";
    homepage = "https://github.com/tree-sitter-grammars/tree-sitter-markdown";
    changelog = "https://github.com/tree-sitter-grammars/tree-sitter-markdown/releases/tag/${src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      GaetanLepage
      gepbird
    ];
  };
}
