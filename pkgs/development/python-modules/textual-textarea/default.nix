{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  # dependencies
  pyperclip,
  # tests
  pytest-asyncio,
  pytestCheckHook,
  textual,
  tree-sitter,
  tree-sitter-python,
  tree-sitter-sql,
}:

buildPythonPackage (finalAttrs: {
  pname = "textual-textarea";
  version = "0.17.2";

  src = fetchFromGitHub {
    owner = "tconbeer";
    repo = "textual-textarea";
    tag = "v${finalAttrs.version}";
    hash = "sha256-y+2WvqD96eYkDEJn5qCGfGFNiJFAcF4KWWNgAIZUqJo=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    pyperclip
    textual
    tree-sitter
    tree-sitter-python
    tree-sitter-sql
  ]
  ++ textual.optional-dependencies.syntax;

  disabledTests = [
    # AssertionError: assert None == 'word'
    # https://github.com/tconbeer/textual-textarea/issues/312
    "test_autocomplete"
    "test_autocomplete_with_types"
  ];

  pyproject = true;
  pythonImportsCheck = [ "textual_textarea" ];

  pythonRelaxDeps = [
    "textual"
  ];

  meta = {
    description = "Text area (multi-line input) with syntax highlighting for Textual";
    homepage = "https://github.com/tconbeer/textual-textarea";
    changelog = "https://github.com/tconbeer/textual-textarea/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pcboy ];
  };
})
