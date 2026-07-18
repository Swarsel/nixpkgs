{
  lib,
  fetchFromGitHub,
  alembic,
  buildPythonPackage,
  flask,
  flask-script,
  flask-sqlalchemy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "flask-migrate";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "miguelgrinberg";
    repo = "Flask-Migrate";
    tag = "v${version}";
    hash = "sha256-7xQu0Y6aM9WWuH2ImuaopbBS2jE9pVChekVp7SEMHCc=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    alembic
    flask
    flask-sqlalchemy
  ];

  nativeCheckInputs = [
    pytestCheckHook
    flask-script
  ];

  pyproject = true;
  pythonImportsCheck = [ "flask_migrate" ];

  meta = {
    description = "SQLAlchemy database migrations for Flask applications using Alembic";
    homepage = "https://github.com/miguelgrinberg/Flask-Migrate";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gador ];
  };
}
