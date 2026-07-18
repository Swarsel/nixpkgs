{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyserial,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyW800rf32";
  version = "0.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-i0XXqohKY5pWIjcOCUxUQdx/FSSqgTnTaWcDxnIYjMk=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ pyserial ];
  pyproject = true;
  pythonImportsCheck = [ "W800rf32" ];

  meta = {
    description = "Python library to communicate with the W800rf32 family of devices";
    homepage = "https://github.com/horga83/pyW800rf32";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
