{
  lib,
  stdenv,
  fetchFromGitHub,
  # tests
  asyncpg,
  buildPythonPackage,
  django,
  # dependencies
  numpy,
  peewee,
  pg8000,
  postgresql,
  postgresqlTestHook,
  psycopg,
  psycopg-pool,
  psycopg2,
  pytest-asyncio,
  pytestCheckHook,
  scipy,
  # build-system
  setuptools,
  sqlalchemy,
  sqlmodel,
}:

buildPythonPackage rec {
  pname = "pgvector";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "pgvector";
    repo = "pgvector-python";
    tag = "v${version}";
    hash = "sha256-jzUZK3zQxqajVqGbaQzLPzvK/k3Wck9jX95kkBH2IlY=";
  };

  env = {
    PGDATABASE = "pgvector_python_test";
    USER = "test_user";
    postgresqlEnableTCP = 1;
    postgresqlTestUserOptions = "LOGIN SUPERUSER";
  };

  doCheck = lib.meta.availableOn stdenv.buildPlatform postgresqlTestHook;

  nativeCheckInputs = [
    asyncpg
    django
    peewee
    pg8000
    psycopg
    psycopg.pool
    psycopg2
    psycopg-pool
    (postgresql.withPackages (p: with p; [ pgvector ]))
    postgresqlTestHook
    pytest-asyncio
    pytestCheckHook
    scipy
    sqlalchemy
    sqlmodel
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];
  dependencies = [ numpy ];

  disabledTestPaths = [
    # DB error
    "tests/test_pg8000.py"
    "tests/test_sqlalchemy.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pgvector" ];

  meta = {
    description = "Pgvector support for Python";
    homepage = "https://github.com/pgvector/pgvector-python";
    changelog = "https://github.com/pgvector/pgvector-python/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
