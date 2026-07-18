{
  lib,
  buildPythonPackage,
  fetchPypi,
  pycryptodome,
  pytestCheckHook,
  requests,
  setuptools,
  setuptools-scm,
  six,
}:

buildPythonPackage rec {
  pname = "httpsig";
  version = "1.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-cdbVAkYSnE98/sIPXlfjUdK4SS1jHMKqlnkUrPkfbOY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    pycryptodome
    requests
    six
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "httpsig" ];

  meta = {
    description = "Sign HTTP requests with secure signatures";
    homepage = "https://github.com/ahknight/httpsig";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ srhb ];
  };
}
