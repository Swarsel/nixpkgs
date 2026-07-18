{
  lib,
  # tests
  black,
  buildPythonPackage,
  fetchPypi,
  # dependencies
  mako,
  pytest-xdist,
  pytestCheckHook,
  python-dateutil,
  # build-system
  setuptools,
  sqlalchemy,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "alembic";
  version = "1.18.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-g6xrgTWVloFvs7iTCZhBoIYvIReyljJY6WXXDcYvuGY=";
  };

  nativeCheckInputs = [
    black
    pytestCheckHook
    pytest-xdist
    python-dateutil
  ];

  build-system = [ setuptools ];

  dependencies = [
    mako
    sqlalchemy
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "alembic" ];

  meta = {
    description = "Database migration tool for SQLAlchemy";
    homepage = "https://bitbucket.org/zzzeek/alembic";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "alembic";
  };
}
