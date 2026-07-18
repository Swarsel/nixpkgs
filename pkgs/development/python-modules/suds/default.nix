{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "suds";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "suds-community";
    repo = "suds";
    tag = "v${version}";
    hash = "sha256-YdL+zDelRspQ6VMqa45vK1DDS3HjFvKE1P02USVBrEo=";
  };

  env.SUDS_PACKAGE = "suds";

  nativeCheckInputs = [
    pytestCheckHook
    six
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "suds" ];

  meta = {
    description = "Lightweight SOAP python client for consuming Web Services";
    homepage = "https://github.com/suds-community/suds";
    changelog = "https://github.com/suds-community/suds/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ wrmilling ];
  };
}
