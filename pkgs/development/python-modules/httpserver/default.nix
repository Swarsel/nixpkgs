{
  lib,
  buildPythonPackage,
  docopt,
  fetchPypi,
  freezegun,
  pytestCheckHook,
  selenium,
  setuptools,
}:

buildPythonPackage rec {
  pname = "httpserver";
  version = "1.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-W8Pa+CUS8vCzEcymjY6no5GMdSDSZs4bhmDtRsR4wuA=";
  };

  nativeCheckInputs = [
    freezegun
    selenium
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ docopt ];

  disabledTestPaths = [
    # Tests want driver for Firefox
    "tests/test_selenium.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "httpserver" ];

  meta = {
    description = "Asyncio implementation of an HTTP server";
    homepage = "https://github.com/thomwiggers/httpserver";
    license = with lib.licenses; [ bsd3 ];
    maintainers = [ ];
    mainProgram = "httpserver";
  };
}
