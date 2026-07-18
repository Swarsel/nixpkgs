{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "clearpasspy";
  version = "1.1.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-HAi9z7DT5g0Pkr+rASUK18/tEsorWXScCODE95Q+ZZ0=";
  };

  # Package has no tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "clearpasspy" ];
  pythonRelaxDeps = [ "requests" ];

  meta = {
    description = "ClearPass API Python Library";
    homepage = "https://github.com/zemerick1/clearpasspy";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
