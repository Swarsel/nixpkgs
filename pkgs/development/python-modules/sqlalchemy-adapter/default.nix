{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pycasbin,
  pytestCheckHook,
  setuptools,
  sqlalchemy,
}:
buildPythonPackage (finalAttrs: {
  pname = "sqlalchemy-adapter";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "officialpycasbin";
    repo = "sqlalchemy-adapter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FjxRSJ+3IIdtKkpZvkL/KzH7gn4IJjCTchABglfcyQ4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    pycasbin
    sqlalchemy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "sqlalchemy_adapter"
  ];

  meta = {
    description = "SQLAlchemy Adapter for PyCasbin";
    homepage = "https://github.com/officialpycasbin/sqlalchemy-adapter";
    changelog = "https://github.com/apache/casbin-python-sqlalchemy-adapter/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ daspk04 ];
  };
})
