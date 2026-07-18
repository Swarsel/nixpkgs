{
  lib,
  fetchFromGitHub,
  blinker,
  buildPythonPackage,
  flask,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "flask-principal";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "pallets-eco";
    repo = "flask-principal";
    tag = version;
    hash = "sha256-E9urzZc7/QtzAohSNAJsQtykrplb+MC189VGZI5kmEE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    flask
    blinker
  ];

  enabledTestPaths = [ "test_principal.py" ];
  pyproject = true;
  pythonImportsCheck = [ "flask_principal" ];

  meta = {
    description = "Identity management for flask";
    homepage = "http://packages.python.org/Flask-Principal/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
