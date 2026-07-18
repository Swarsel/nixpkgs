{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  psycopg2,
  pymysql,
  pytest-sugar,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  sqlalchemy,
}:

buildPythonPackage rec {
  pname = "sqlalchemy-jsonfield";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "penguinolog";
    repo = "sqlalchemy_jsonfield";
    tag = version;
    hash = "sha256-4zLXB3UQh6pgQ80KrxkLeC5yiv1R8t2+JmSukmGXr7I=";
  };

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    sqlalchemy
    setuptools
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-sugar
    pymysql
    psycopg2
  ];

  format = "setuptools";
  pythonImportsCheck = [ "sqlalchemy_jsonfield" ];

  meta = {
    description = "SQLALchemy JSONField implementation for storing dicts at SQL independently from JSON type support";
    homepage = "https://github.com/penguinolog/sqlalchemy_jsonfield";
    changelog = "https://github.com/penguinolog/sqlalchemy_jsonfield/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
