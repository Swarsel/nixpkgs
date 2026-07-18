{
  lib,
  fetchFromGitHub,
  aiomysql,
  aiopg,
  aiosqlite,
  asyncmy,
  asyncpg,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  sqlalchemy,
}:

buildPythonPackage rec {
  pname = "databases";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "encode";
    repo = "databases";
    tag = version;
    hash = "sha256-Zf9QqBgDhWAnHdNvzjXtri5rdT00BOjc4YTNzJALldM=";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ sqlalchemy ];
  nativeCheckInputs = [ pytestCheckHook ];

  disabledTestPaths = [
    # circular dependency on starlette
    "tests/test_integration.py"
    # TEST_DATABASE_URLS is not set.
    "tests/test_databases.py"
    "tests/test_connection_options.py"
  ];

  optional-dependencies = {
    aiomysql = [ aiomysql ];
    aiopg = [ aiopg ];
    aiosqlite = [ aiosqlite ];
    asyncmy = [ asyncmy ];
    asyncpg = [ asyncpg ];
    mysql = [ aiomysql ];
    postgresql = [ asyncpg ];
    sqlite = [ aiosqlite ];
  };

  pyproject = true;
  pythonImportsCheck = [ "databases" ];

  meta = {
    description = "Async database support for Python";
    homepage = "https://github.com/encode/databases";
    changelog = "https://github.com/encode/databases/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
