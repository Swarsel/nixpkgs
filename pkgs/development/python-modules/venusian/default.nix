{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "venusian";
  version = "3.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-U0+zs1VmkoPrOVRYGTHl0dBx/OYdAp1Y8yGaXjpvDEE=";
  };

  nativeBuildInputs = [ setuptools ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  checkPhase = ''
    pytest
  '';

  pyproject = true;

  meta = {
    description = "Library for deferring decorator actions";
    homepage = "https://pylonsproject.org/";
    license = lib.licenses.bsd0;
    maintainers = [ ];
  };
}
