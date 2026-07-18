{
  lib,
  buildPythonPackage,
  fetchPypi,
  pathspec,
  setuptools,
  tree-sitter-language-pack,
}:

buildPythonPackage rec {
  pname = "grep-ast";
  version = "0.9.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-YgokKkST5nITONHJpsI0rmUfh3T0kkptz5D2hl1LLuM=";
    pname = "grep_ast";
  };

  build-system = [ setuptools ];

  dependencies = [
    pathspec
    tree-sitter-language-pack
  ];

  pyproject = true;
  # Tests disabled due to pending update from tree-sitter-languages to tree-sitter-language-pack
  # nativeCheckInputs = [ pytestCheckHook ];
  pythonImportsCheck = [ "grep_ast" ];

  meta = {
    description = "Python implementation of the ast-grep tool";
    homepage = "https://github.com/paul-gauthier/grep-ast";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ greg ];
    mainProgram = "grep-ast";
  };
}
