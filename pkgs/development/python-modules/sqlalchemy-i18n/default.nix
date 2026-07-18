{
  lib,
  buildPythonPackage,
  fetchPypi,
  postgresql,
  postgresqlTestHook,
  psycopg2,
  pytestCheckHook,
  setuptools,
  six,
  sqlalchemy,
  sqlalchemy-utils,
}:

buildPythonPackage rec {
  pname = "sqlalchemy-i18n";
  version = "1.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-3jM3ZIOlgcoUIY2PV6EURmxfcrZ0qVg5tsRWSm5neW8=";
    pname = "SQLAlchemy-i18n";
  };

  env = {
    PGDATABASE = "sqlalchemy_i18n_test";
    postgresqlEnableTCP = 1;
  };

  nativeCheckInputs = [
    postgresql
    postgresqlTestHook
    psycopg2
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    sqlalchemy
    sqlalchemy-utils
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "sqlalchemy_i18n" ];

  meta = {
    description = "Internationalization extension for SQLAlchemy models";
    homepage = "https://github.com/kvesteri/sqlalchemy-i18n";
    license = lib.licenses.bsd3;
    # sqlalchemy.exc.InvalidRequestError: The 'sqlalchemy.orm.mapper()' function is removed as of SQLAlchemy 2.0.
    broken = lib.versionAtLeast sqlalchemy.version "2";
  };
}
