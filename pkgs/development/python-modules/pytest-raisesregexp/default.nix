{
  lib,
  buildPythonPackage,
  fetchPypi,
  py,
  pytest,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pytest-raisesregexp";
  version = "2.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-tUNySU/B8ROIsbk0ius2tpYJaZ649G4OAQr8cz14I2o=";
  };

  buildInputs = [
    py
    pytest
  ];

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Simple pytest plugin to look for regex in Exceptions";
    homepage = "https://github.com/Walkman/pytest_raisesregexp";
    license = with lib.licenses; [ mit ];
  };
}
