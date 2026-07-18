{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # install_requires
  certifi,
  # build_requires
  cython,
  importlib-metadata,
  lz4,
  numpy,
  orjson,
  pandas,
  pyarrow,
  # not in tests_require, but should be
  pytest-dotenv,
  pytestCheckHook,
  pytz,
  # extras_require
  sqlalchemy,
  urllib3,
  zstandard,
}:
buildPythonPackage rec {
  pname = "clickhouse-connect";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "ClickHouse";
    repo = "clickhouse-connect";
    tag = "v${version}";
    hash = "sha256-D2D0sOFb0gcbLfMigYn0/GrT8zJav2Q6T39dONLxui4=";
  };

  nativeBuildInputs = [ cython ];

  propagatedBuildInputs = [
    certifi
    importlib-metadata
    urllib3
    pytz
    zstandard
    lz4
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-dotenv
  ]
  ++ optional-dependencies.sqlalchemy
  ++ optional-dependencies.numpy
  ++ optional-dependencies.pandas;

  # These tests require a running ClickHouse instance or a reachable HTTP endpoint.
  disabledTestPaths = [
    "tests/integration_tests"
    "tests/unit_tests/test_driver/test_httpclient.py"
  ];

  enableParallelBuilding = true;
  format = "setuptools";

  optional-dependencies = {
    arrow = [ pyarrow ];
    numpy = [ numpy ];
    orjson = [ orjson ];
    pandas = [ pandas ];
    sqlalchemy = [ sqlalchemy ];
  };

  pythonImportsCheck = [
    "clickhouse_connect"
    "clickhouse_connect.driverc.buffer"
    "clickhouse_connect.driverc.dataconv"
    "clickhouse_connect.driverc.npconv"
  ];

  setupPyBuildFlags = [ "--inplace" ];

  meta = {
    description = "ClickHouse Database Core Driver for Python, Pandas, and Superset";
    homepage = "https://github.com/ClickHouse/clickhouse-connect";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ cpcloud ];
  };
}
