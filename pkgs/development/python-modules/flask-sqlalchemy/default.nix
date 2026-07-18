{
  lib,
  buildPythonPackage,
  fetchPypi,
  flask,
  flit-core,
  mock,
  pytestCheckHook,
  pythonAtLeast,
  pythonOlder,
  sqlalchemy,
}:

buildPythonPackage rec {
  pname = "flask-sqlalchemy";
  version = "3.1.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-5LaLuIGALdoafYeLL8hMBtHuV/tAuHTT3Jfav6NrgxI=";
    pname = "flask_sqlalchemy";
  };

  nativeBuildInputs = [ flit-core ];

  propagatedBuildInputs = [
    flask
    sqlalchemy
  ];

  doCheck = pythonOlder "3.13"; # https://github.com/pallets-eco/flask-sqlalchemy/issues/1379

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  disabledTests = [
    # flaky
    "test_session_scoping_changing"
    # https://github.com/pallets-eco/flask-sqlalchemy/issues/1378
    "test_explicit_table"
  ];

  pyproject = true;

  pytestFlags = lib.optionals (pythonAtLeast "3.12") [
    # datetime.datetime.utcnow() is deprecated and scheduled for removal in a future version.
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [ "flask_sqlalchemy" ];

  meta = {
    description = "SQLAlchemy extension for Flask";
    homepage = "http://flask-sqlalchemy.pocoo.org/";
    changelog = "https://github.com/pallets-eco/flask-sqlalchemy/blob/${version}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ gerschtli ];
  };
}
