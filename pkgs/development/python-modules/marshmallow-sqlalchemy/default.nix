{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  marshmallow,
  packaging,
  pytest-lazy-fixtures,
  pytestCheckHook,
  sqlalchemy,
}:

buildPythonPackage rec {
  pname = "marshmallow-sqlalchemy";
  version = "1.5.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-5RGSwgR3BkWi+rDXL0T4eJJy7vdZUfhLFgjWtLC/4OY=";
    pname = "marshmallow_sqlalchemy";
  };

  propagatedBuildInputs = [
    marshmallow
    packaging
    sqlalchemy
  ];

  nativeCheckInputs = [
    pytest-lazy-fixtures
    pytestCheckHook
  ];

  build-system = [ flit-core ];
  pyproject = true;
  pythonImportsCheck = [ "marshmallow_sqlalchemy" ];

  meta = {
    description = "SQLAlchemy integration with marshmallow";
    homepage = "https://github.com/marshmallow-code/marshmallow-sqlalchemy";
    changelog = "https://github.com/marshmallow-code/marshmallow-sqlalchemy/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
