{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  defusedxml,
  # tests
  gitpython,
  jsondiff,
  jsonref,
  jsonschema,
  latex2mathml,
  pandas,
  pillow,
  # build-system
  poetry-core,
  pydantic,
  pytestCheckHook,
  pyyaml,
  requests,
  semchunk,
  setuptools,
  tabulate,
  transformers,
  tree-sitter,
  typer,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "docling-core";
  version = "2.73.0";

  src = fetchFromGitHub {
    owner = "docling-project";
    repo = "docling-core";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aK+XHZjKsmFPgRv0oDed1CdBwZags/zcALumgcfQjjY=";
  };

  nativeCheckInputs = [
    gitpython
    jsondiff
    pytestCheckHook
    requests
  ];

  build-system = [
    poetry-core
    setuptools
  ];

  dependencies = [
    defusedxml
    jsonref
    jsonschema
    latex2mathml
    pandas
    pillow
    pydantic
    pyyaml
    semchunk
    tabulate
    transformers
    tree-sitter
    typer
    typing-extensions
  ];

  disabledTestPaths = [
    # attempts to download models
    "test/test_code_chunker.py"
    "test/test_code_chunking_strategy.py"
    "test/test_hybrid_chunker.py"
    "test/test_line_chunker.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "docling_core" ];

  pythonRelaxDeps = [
    "defusedxml"
    "pillow"
    "typer"
  ];

  meta = {
    description = "Python library to define and validate data types in Docling";
    homepage = "https://github.com/docling-project/docling-core";
    changelog = "https://github.com/docling-project/docling-core/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
