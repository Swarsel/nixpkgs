{
  lib,
  buildPythonPackage,
  email-validator,
  fetchPypi,
  flask,
  hatchling,
  itsdangerous,
  pytestCheckHook,
  setuptools,
  wtforms,
}:

buildPythonPackage rec {
  pname = "flask-wtf";
  version = "1.2.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-edLuHkNs9XC8y32RZTP6GHV6LxjCkKzP+rG5oLaEZms=";
    pname = "flask_wtf";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatchling
    setuptools
  ];

  dependencies = [
    flask
    itsdangerous
    wtforms
  ];

  optional-dependencies = {
    email = [ email-validator ];
  };

  pyproject = true;
  pythonImportsCheck = [ "flask_wtf" ];

  meta = {
    description = "Simple integration of Flask and WTForms";
    homepage = "https://github.com/pallets-eco/flask-wtf/";
    changelog = "https://github.com/pallets-eco/flask-wtf/releases/tag/v${version}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      mic92
      anthonyroussel
    ];
  };
}
