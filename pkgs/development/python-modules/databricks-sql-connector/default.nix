{
  lib,
  fetchFromGitHub,
  alembic,
  buildPythonPackage,
  lz4,
  numpy,
  oauthlib,
  openpyxl,
  pandas,
  poetry-core,
  pyarrow,
  pybreaker,
  pyjwt,
  pytestCheckHook,
  requests,
  sqlalchemy,
  thrift,
  urllib3,
}:

buildPythonPackage rec {
  pname = "databricks-sql-connector";
  version = "4.2.4";

  src = fetchFromGitHub {
    owner = "databricks";
    repo = "databricks-sql-python";
    tag = "v${version}";
    hash = "sha256-QoauhA2Zx2UvlCuKe9mxaOFJKpglVHQmPVVS56np4A0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    alembic
    lz4
    numpy
    oauthlib
    openpyxl
    pandas
    pyarrow
    pybreaker
    pyjwt
    sqlalchemy
    thrift
    requests
    urllib3
  ];

  enabledTestPaths = [ "tests/unit" ];
  pyproject = true;
  pythonImportsCheck = [ "databricks" ];

  pythonRelaxDeps = [
    "pandas"
    "pyarrow"
    "thrift"
  ];

  meta = {
    description = "Databricks SQL Connector for Python";
    homepage = "https://docs.databricks.com/dev-tools/python-sql-connector.html";
    changelog = "https://github.com/databricks/databricks-sql-python/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ harvidsen ];
  };
}
