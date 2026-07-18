{
  lib,
  fetchFromGitHub,
  aiosqlite,
  buildPythonPackage,
  flask,
  flit-core,
  pytestCheckHook,
  sqlalchemy,
}:

buildPythonPackage rec {
  pname = "flask-sqlalchemy-lite";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "pallets-eco";
    repo = "flask-sqlalchemy-lite";
    tag = version;
    hash = "sha256-KX4kpqgvNlcAe4NSWaSkcgtPQINmeQOx46/4uFM8q8A=";
  };

  nativeCheckInputs = [
    aiosqlite
    pytestCheckHook
  ];

  build-system = [ flit-core ];

  dependencies = [
    flask
    sqlalchemy
  ]
  ++ flask.optional-dependencies.async
  ++ sqlalchemy.optional-dependencies.asyncio;

  pyproject = true;
  pythonImportsCheck = [ "flask_sqlalchemy_lite" ];

  meta = {
    description = "Integrate SQLAlchemy with Flask";
    homepage = "https://github.com/pallets-eco/flask-sqlalchemy-lite";
    changelog = "https://github.com/pallets-eco/flask-sqlalchemy-lite/blob/${src.tag}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
