{
  lib,
  fetchFromGitHub,
  alembic,
  buildPythonPackage,
  flask,
  flask-sqlalchemy,
  flask-sqlalchemy-lite,
  flit-core,
  pytestCheckHook,
  sqlalchemy,
}:

buildPythonPackage rec {
  pname = "flask-alembic";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "pallets-eco";
    repo = "flask-alembic";
    tag = version;
    hash = "sha256-g5xl5CEfSZUbZxCLYykjd94eVjxzBAkgoBcR4y7IYfM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    flask-sqlalchemy
    flask-sqlalchemy-lite
  ];

  build-system = [ flit-core ];

  dependencies = [
    alembic
    flask
    sqlalchemy
  ];

  pyproject = true;
  pythonImportsCheck = [ "flask_alembic" ];

  meta = {
    homepage = "https://github.com/pallets-eco/flask-alembic";
    changelog = "https://github.com/pallets-eco/flask-alembic/blob/${src.tag}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ erictapen ];
  };
}
