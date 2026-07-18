{
  lib,
  buildPythonPackage,
  fetchPypi,
  flask,
  flask-login,
  flask-sqlalchemy,
  packaging,
  psycopg2,
  pymysql,
  pytestCheckHook,
  setuptools,
  sqlalchemy,
}:

buildPythonPackage rec {
  pname = "sqlalchemy-continuum";
  version = "1.7.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-MO+qJqDGMlrHDQNIR+bpcq5wYWtlU7sBaif37S8aEAM=";
    pname = "sqlalchemy_continuum";
  };

  nativeCheckInputs = [
    packaging
    psycopg2
    pymysql
    pytestCheckHook
  ]
  ++ optional-dependencies.flask
  ++ optional-dependencies.flask-login
  ++ optional-dependencies.flask-sqlalchemy;

  preCheck = ''
    # Indicate tests that we don't have a database server at hand
    export DB=sqlite
  '';

  build-system = [ setuptools ];

  dependencies = [
    sqlalchemy
  ];

  optional-dependencies = {
    flask = [ flask ];
    flask-login = [ flask-login ];
    flask-sqlalchemy = [ flask-sqlalchemy ];
  };

  pyproject = true;
  pythonImportsCheck = [ "sqlalchemy_continuum" ];

  meta = {
    description = "Versioning and auditing extension for SQLAlchemy";
    homepage = "https://github.com/kvesteri/sqlalchemy-continuum/";
    changelog = "https://github.com/kvesteri/sqlalchemy-continuum/blob/${version}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
