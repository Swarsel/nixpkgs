{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pandas,
  polars,
  pyarrow,
  pytest-asyncio,
  pytest-textual-snapshot,
  pytestCheckHook,
  pytz,
  textual,
  tzdata,
}:

buildPythonPackage rec {
  pname = "textual-fastdatatable";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "tconbeer";
    repo = "textual-fastdatatable";
    tag = "v${version}";
    hash = "sha256-gm1h+r8rZO1/9sXoNwqVuBbv7CpZm2a3YAMHRHGg5uo=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-textual-snapshot
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ hatchling ];

  dependencies = [
    pandas
    pyarrow
    pytz
    textual
    tzdata
  ]
  ++ textual.optional-dependencies.syntax;

  disabledTestPaths = [
    # Tests are comparing CLI output
    "tests/snapshot_tests/test_snapshots.py"
  ];

  optional-dependencies = {
    polars = [ polars ];
  };

  pyproject = true;
  pythonImportsCheck = [ "textual_fastdatatable" ];

  pythonRelaxDeps = [
    "numpy"
    "pandas"
    "pyarrow"
  ];

  meta = {
    description = "Performance-focused reimplementation of Textual's DataTable widget, with a pluggable data storage backend";
    homepage = "https://github.com/tconbeer/textual-fastdatatable";
    changelog = "https://github.com/tconbeer/textual-fastdatatable/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pcboy ];
  };
}
