{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flask,
  flask-sqlalchemy,
  flit-core,
  marshmallow,
  marshmallow-sqlalchemy,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "flask-marshmallow";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "marshmallow-code";
    repo = "flask-marshmallow";
    tag = version;
    hash = "sha256-IzeVVkyf4BRxtUVQIfzAvyjaKG+BLwhruXZHFJ6iGmw=";
  };

  nativeCheckInputs = [ pytestCheckHook ] ++ optional-dependencies.sqlalchemy;
  build-system = [ flit-core ];

  dependencies = [
    flask
    marshmallow
  ];

  optional-dependencies = {
    sqlalchemy = [
      flask-sqlalchemy
      marshmallow-sqlalchemy
    ];
  };

  pyproject = true;

  pytestFlags = [
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [ "flask_marshmallow" ];

  meta = {
    description = "Flask + marshmallow for beautiful APIs";
    homepage = "https://github.com/marshmallow-code/flask-marshmallow";
    changelog = "https://github.com/marshmallow-code/flask-marshmallow/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nickcao ];
  };
}
