{
  lib,
  fetchFromGitHub,
  # optionals
  aiomysql,
  # TODO: aioodbc
  aiosqlite,
  asyncmy,
  asyncpg,
  buildPythonPackage,
  cx-oracle,
  # build
  cython,
  # propagates
  greenlet,
  isPyPy,
  mariadb,
  # tests
  mock,
  mypy,
  mysql-connector-python,
  mysqlclient,
  nix-update-script,
  oracledb,
  pg8000,
  psycopg,
  psycopg2,
  psycopg2cffi,
  pymssql,
  pymysql,
  pyodbc,
  pytest-xdist,
  pytestCheckHook,
  setuptools,
  sqlcipher3,
  types-greenlet,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "sqlalchemy";
  version = "2.0.51";

  src = fetchFromGitHub {
    owner = "sqlalchemy";
    repo = "sqlalchemy";
    tag = "rel_${lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    hash = "sha256-2t3NhfLiu/rLI2yvFPK9uQXGyzqNUj7ImDRx0EasdsI=";
  };

  postPatch = ''
    sed -i '/tag_build = dev/d' setup.cfg
  '';

  nativeCheckInputs = [
    pytest-xdist
    pytestCheckHook
    mock
  ];

  build-system = [ setuptools ] ++ lib.optionals (!isPyPy) [ cython ];

  dependencies = [
    greenlet
    typing-extensions
  ];

  disabledTestPaths = [
    # typing correctness, not interesting
    "test/ext/mypy"
    "test/typing"
    # slow and high memory usage, not interesting
    "test/aaa_profiling"
  ];

  optional-dependencies = lib.fix (self: {
    aiomysql = [ aiomysql ] ++ self.asyncio;
    aiosqlite = [ aiosqlite ] ++ self.asyncio;
    asyncio = [ greenlet ];
    # TODO: aioodbc
    asyncmy = [ asyncmy ] ++ self.asyncio;
    mariadb_connector = [ mariadb ];
    mssql = [ pyodbc ];
    mssql_pymysql = [ pymssql ];
    mssql_pyodbc = [ pyodbc ];

    mypy = [
      mypy
      types-greenlet
    ];

    mysql = [ mysqlclient ];
    mysql_connector = [ mysql-connector-python ];
    oracle = [ cx-oracle ];
    oracle_oracledb = [ oracledb ];
    postgresql = [ psycopg2 ];
    postgresql_asyncpg = [ asyncpg ] ++ self.asyncio;
    postgresql_pg8000 = [ pg8000 ];
    postgresql_psycopg = [ psycopg ];
    postgresql_psycopg2binary = [ psycopg2 ];
    postgresql_psycopg2cffi = [ psycopg2cffi ];
    postgresql_psycopgbinary = [ psycopg ];
    pymysql = [ pymysql ];
    sqlcipher = [ sqlcipher3 ];
  });

  pyproject = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^rel_([0-9]+)_([0-9]+)_([0-9]+)$"
    ];
  };

  meta = {
    description = "Python SQL toolkit and Object Relational Mapper";
    homepage = "http://www.sqlalchemy.org/";
    changelog = "https://github.com/sqlalchemy/sqlalchemy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
  };
})
