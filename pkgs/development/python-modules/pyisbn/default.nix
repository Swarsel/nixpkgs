{
  lib,
  buildPythonPackage,
  fetchPypi,
  hypothesis,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyisbn";
  version = "1.3.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-cPVjgXlps/8IUGieULx/917puGXD+A+DWWSxMGxO1Rk=";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pyisbn" ];

  meta = {
    description = "Python module for working with 10- and 13-digit ISBNs";
    homepage = "https://github.com/JNRowe/pyisbn";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
  };
}
