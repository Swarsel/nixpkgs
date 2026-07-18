{
  lib,
  fetchFromGitHub,
  # optionals
  aiomysql,
  aiosqlite,
  asyncmy,
  asyncpg,
  buildPythonPackage,
  cx-oracle,
  # dependencies
  greenlet,
  mariadb,
  # tests
  mock,
  mypy,
  mysql-connector-python,
  mysqlclient,
  pg8000,
  psycopg2,
  psycopg2cffi,
  # TODO: pymssql
  pymysql,
  pyodbc,
  pytest-xdist,
  pytestCheckHook,
  # build-system
  setuptools,
  # TODO: sqlcipher3
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "sqlalchemy";
  version = "1.4.54-unstable-2025-08-16";

  src = fetchFromGitHub {
    owner = "sqlalchemy";
    repo = "sqlalchemy";
    rev = "1712b81a5b8d9d3abd5a85fbb089470f0bc38cdd";
    hash = "sha256-BqhH6CqvWQvUllCh0JAIM/K+W3KtLIRe30WGJrqafoI=";
  };

  postPatch = ''
    sed -i '/tag_build = dev/d' setup.cfg
  '';

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ greenlet ];

  nativeCheckInputs = [
    pytest-xdist
    pytestCheckHook
    mock
  ];

  disabledTestPaths = [
    # typing correctness, not interesting
    "test/ext/mypy"
    # slow and high memory usage, not interesting
    "test/aaa_profiling"
  ];

  optional-dependencies = lib.fix (self: {
    aiomysql = [ aiomysql ] ++ self.asyncio;

    aiosqlite = [
      aiosqlite
      typing-extensions
    ]
    ++ self.asyncio;

    asyncio = [ greenlet ];
    asyncmy = [ asyncmy ] ++ self.asyncio;
    mariadb_connector = [ mariadb ];
    mssql = [ pyodbc ];

    mssql_pymysql = [
      # TODO: pymssql
    ];

    mssql_pyodbc = [ pyodbc ];
    mypy = [ mypy ];
    mysql = [ mysqlclient ];
    mysql_connector = [ mysql-connector-python ];
    oracle = [ cx-oracle ];
    postgresql = [ psycopg2 ];
    postgresql_asyncpg = [ asyncpg ] ++ self.asyncio;
    postgresql_pg8000 = [ pg8000 ];
    postgresql_psycopg2binary = [ psycopg2 ];
    postgresql_psycopg2cffi = [ psycopg2cffi ];
    pymysql = [ pymysql ];

    sqlcipher = [
      # TODO: sqlcipher3
    ];
  });

  pyproject = true;
  pythonImportsCheck = [ "sqlalchemy" ];

  meta = {
    description = "Database Toolkit for Python";
    homepage = "https://github.com/sqlalchemy/sqlalchemy";

    changelog =
      let
        shortVersion = lib.replaceString "." "" (lib.versions.majorMinor version);
      in
      "https://github.com/sqlalchemy/sqlalchemy/blob/${src.rev}/doc/build/changelog/changelog_${shortVersion}.rst";

    license = lib.licenses.mit;
  };
}
