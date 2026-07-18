{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  duckdb,
  # testing
  fsspec,
  hypothesis,
  pandas,
  # build-system
  poetry-core,
  pyarrow,
  pytest-remotedata,
  pytestCheckHook,
  pythonAtLeast,
  pythonOlder,
  snapshottest,
  sqlalchemy,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "duckdb-engine";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "Mause";
    repo = "duckdb_engine";
    tag = "v${version}";
    hash = "sha256-AhYCiIhi7jMWKIdDwZZ8MgfDg3F02/jooGLOp6E+E5g=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  checkInputs = [
    fsspec
    hypothesis
    pandas
    pyarrow
    pytest-remotedata
    typing-extensions
  ]
  ++ lib.optionals (pythonOlder "3.12") [
    # requires wasmer which is broken for python 3.12
    # https://github.com/wasmerio/wasmer-python/issues/778
    snapshottest
  ];

  preCheck = ''
    export HOME="$(mktemp -d)"
  '';

  build-system = [ poetry-core ];

  dependencies = [
    duckdb
    sqlalchemy
  ];

  disabledTestMarks = [
    "remote_data"
  ];

  disabledTestPaths = lib.optionals (pythonAtLeast "3.12") [
    # requires snapshottest
    "duckdb_engine/tests/test_datatypes.py"
  ];

  disabledTests = [
    # user agent not available in nixpkgs
    "test_user_agent"
    "test_user_agent_with_custom_user_agent"

    # Fail under nixpkgs-review in the sandbox due to "missing tables"
    "test_get_columns"
    "test_get_foreign_keys"
    "test_get_check_constraints"
    "test_get_unique_constraints"
    # https://github.com/Mause/duckdb_engine/issues/1379
    "test_reflect"
    "test_get_multi_columns"
    "test_table_reflect"
    "test_comment_support"
    "test_361"
    "test_reflection"
    "test_fetch_arrow"
  ];

  pyproject = true;
  pythonImportsCheck = [ "duckdb_engine" ];

  meta = {
    description = "SQLAlchemy driver for duckdb";
    homepage = "https://github.com/Mause/duckdb_engine";
    changelog = "https://github.com/Mause/duckdb_engine/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cpcloud ];
  };
}
