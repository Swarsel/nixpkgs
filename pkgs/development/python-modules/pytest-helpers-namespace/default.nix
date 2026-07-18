{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  setuptools-declarative-requirements,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pytest-helpers-namespace";
  version = "2021.12.29";

  src = fetchPypi {
    inherit pname version;
    sha256 = "792038247e0021beb966a7ea6e3a70ff5fcfba77eb72c6ec8fd6287af871c35b";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-declarative-requirements
    setuptools-scm
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "pytest_helpers_namespace" ];

  meta = {
    description = "PyTest Helpers Namespace";
    homepage = "https://github.com/saltstack/pytest-helpers-namespace";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
