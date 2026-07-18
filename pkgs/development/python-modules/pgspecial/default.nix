{
  lib,
  stdenv,
  buildPythonPackage,
  click,
  configobj,
  fetchPypi,
  postgresql,
  postgresqlTestHook,
  psycopg,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  sqlparse,
}:

buildPythonPackage rec {
  pname = "pgspecial";
  version = "2.2.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-2mx/zHvve7ATLcIEb3TsZROx/m8MgOVSjWMNFLfEhJ0=";
  };

  env = {
    PGDATABASE = "_test_db";
    PGUSER = "postgres";
  };

  # postgresqlTestHook is not available on Darwin
  doCheck = stdenv.hostPlatform.isLinux;

  nativeCheckInputs = [
    configobj
    pytestCheckHook
    postgresqlTestHook
    postgresql
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    click
    sqlparse
    psycopg
  ];

  disabledTests = [
    "test_slash_d_view_verbose"
    "test_slash_ddp"
    "test_slash_ddp_pattern"
  ];

  pyproject = true;
  pytestFlags = [ "-vvv" ];

  meta = {
    description = "Meta-commands handler for Postgres Database";
    homepage = "https://github.com/dbcli/pgspecial";
    changelog = "https://github.com/dbcli/pgspecial/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.SuperSandro2000 ];
  };
}
