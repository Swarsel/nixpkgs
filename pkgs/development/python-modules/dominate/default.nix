{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dominate";
  version = "2.9.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-VYKEaH2biq4ZBOPWBRrRMt1KjAz1UbN+pOfkKjHRncQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTestPaths = lib.optionals (pythonAtLeast "3.13") [
    # Tests are failing, https://github.com/Knio/dominate/issues/213
    "tests/test_svg.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "dominate" ];

  meta = {
    description = "Library for creating and manipulating HTML documents using an elegant DOM API";
    homepage = "https://github.com/Knio/dominate/";
    changelog = "https://github.com/Knio/dominate/releases/tag/${version}";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ ];
  };
}
