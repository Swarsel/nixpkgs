{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dominate,
  flask,
  pytestCheckHook,
  requests,
  setuptools,
  visitor,
}:

buildPythonPackage rec {
  pname = "flask-bootstrap";
  version = "3.3.7.1";

  src = fetchFromGitHub {
    owner = "mbr";
    repo = "flask-bootstrap";
    tag = version;
    hash = "sha256-TsRSNhrI1jZU/beX3G7LM64IrFagD6AYiluoGzy12jE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests
  ];

  build-system = [ setuptools ];

  dependencies = [
    flask
    visitor
    dominate
  ];

  disabledTests = [
    # requires network access
    "test_bootstrap_version_matches"
    # requires flask-appconfig
    "test_index"
  ];

  pyproject = true;
  pythonImportsCheck = [ "flask_bootstrap" ];

  meta = {
    description = "Ready-to-use Twitter-bootstrap for use in Flask";
    homepage = "https://github.com/mbr/flask-bootstrap";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
