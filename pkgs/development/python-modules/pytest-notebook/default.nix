{
  lib,
  fetchFromGitHub,
  # dependencies
  attrs,
  # tests
  black,
  buildPythonPackage,
  # build-system
  flit-core,
  ipykernel,
  jsonschema,
  nbclient,
  nbdime,
  nbformat,
  # buildInputs
  pytest,
  pytest-cov-stub,
  pytest-regressions,
  pytestCheckHook,
  pythonAtLeast,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "pytest-notebook";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "chrisjsewell";
    repo = "pytest-notebook";
    tag = "v${version}";
    hash = "sha256-LoK0wb7rAbVbgyURCbSfckWvJDef3tPY+7V4YU1IBRU=";
  };

  patches = [
    # Rename pytest_collect_file hook parameter `path` -> `file_path` for pytest 9.
    ./pytest9-collect-hook.patch
  ];

  postPatch = ''
    # we disable the tests relying on coverage for unrelated reasons
    substituteInPlace tests/test_execution.py \
      --replace-fail "from coverage import CoverageData" ""
  '';

  buildInputs = [ pytest ];

  nativeCheckInputs = [
    black
    ipykernel
    pytest-cov-stub
    pytest-regressions
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    flit-core
  ];

  dependencies = [
    attrs
    jsonschema
    nbclient
    nbdime
    nbformat
  ];

  disabledTests = [
    # AssertionError: FILES DIFFER:
    "test_diff_to_string"

    # pytest_notebook.execution.CoverageError: An error occurred while executing coverage start-up
    # TypeError: expected str, bytes or os.PathLike object, not NoneType
    "test_execute_notebook_with_coverage"
    "test_regression_coverage"

    # pytest_notebook.nb_regression.NBRegressionError
    "test_regression_regex_replace_pass"
  ]
  ++ lib.optionals (pythonAtLeast "3.13") [
    # AssertionError: FILES DIFFER:
    "test_documentation"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_notebook" ];

  pythonRelaxDeps = [
    "attrs"
    "nbclient"
  ];

  meta = {
    description = "Pytest plugin for regression testing and regenerating Jupyter Notebooks";
    homepage = "https://github.com/chrisjsewell/pytest-notebook";
    changelog = "https://github.com/chrisjsewell/pytest-notebook/blob/${src.tag}/docs/source/changelog.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
