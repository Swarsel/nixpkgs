{
  lib,
  buildPythonPackage,
  django,
  faker,
  fetchPypi,
  flask,
  flask-sqlalchemy,
  mongoengine,
  mongomock,
  pytestCheckHook,
  setuptools,
  sqlalchemy,
  sqlalchemy-utils,
}:

buildPythonPackage rec {
  pname = "factory-boy";
  version = "3.3.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-hmhi0iYSjfrH8rQWAofomdr1TyYSd4Mn3QPQ4ssePQM=";
    pname = "factory_boy";
  };

  nativeCheckInputs = [
    django
    flask
    flask-sqlalchemy
    mongoengine
    mongomock
    pytestCheckHook
    sqlalchemy
    sqlalchemy-utils
  ];

  build-system = [ setuptools ];
  dependencies = [ faker ];

  disabledTestPaths = [
    # incompatible with latest flask-sqlalchemy
    "examples/flask_alchemy/test_demoapp.py"
  ];

  disabledTests = [
    # Test checks for MongoDB requires an a running DB
    "MongoEngineTestCase"
  ];

  pyproject = true;
  pythonImportsCheck = [ "factory" ];

  meta = {
    description = "Python package to create factories for complex objects";
    homepage = "https://github.com/rbarrois/factory_boy";
    changelog = "https://github.com/FactoryBoy/factory_boy/blob/${version}/docs/changelog.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
