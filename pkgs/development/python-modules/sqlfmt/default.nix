{
  lib,
  fetchFromGitHub,
  # tests
  addBinToPathHook,
  # optional-dependencies
  black,
  buildPythonPackage,
  # dependencies
  click,
  gitpython,
  # build-system
  hatchling,
  jinja2,
  platformdirs,
  pytest-asyncio,
  pytestCheckHook,
  tqdm,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "sqlfmt";
  version = "0.30.0";

  src = fetchFromGitHub {
    owner = "tconbeer";
    repo = "sqlfmt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/8BTH2nuqO+du6PsTPB59L21HvvAIZKDcG1kV9XHxsg=";
  };

  nativeCheckInputs = [
    addBinToPathHook
    pytest-asyncio
    pytestCheckHook
    versionCheckHook
    writableTmpDirAsHomeHook
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  build-system = [ hatchling ];

  dependencies = [
    click
    jinja2
    platformdirs
    tqdm
  ];

  disabledTestPaths = [
    # TypeError: CliRunner.__init__() got an unexpected keyword argument 'mix_stderr'
    "tests/functional_tests/test_end_to_end.py"
    "tests/unit_tests/test_cli.py"
  ];

  optional-dependencies = {
    jinjafmt = [ black ];
    sqlfmt_primer = [ gitpython ];
  };

  pyproject = true;
  pythonImportsCheck = [ "sqlfmt" ];
  pythonRelaxDeps = [ "click" ];

  meta = {
    description = "Formatter for dbt SQL files";
    homepage = "https://github.com/tconbeer/sqlfmt";
    changelog = "https://github.com/tconbeer/sqlfmt/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ pcboy ];
    mainProgram = "sqlfmt";
  };
})
