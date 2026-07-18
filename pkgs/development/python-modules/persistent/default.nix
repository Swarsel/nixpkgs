{
  lib,
  buildPythonPackage,
  # dependencies
  cffi,
  fetchPypi,
  isPyPy,
  # build-systems
  setuptools,
  zope-deferredimport,
  zope-interface,
}:

buildPythonPackage rec {
  pname = "persistent";
  version = "6.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-RwkiFZZTKYZRBcSMFSTp0mF6o88INaxiXDeUBPbL298=";
  };

  build-system = [ setuptools ];

  dependencies = [
    zope-interface
    zope-deferredimport
  ]
  ++ lib.optionals (!isPyPy) [ cffi ];

  pyproject = true;
  pythonImportsCheck = [ "persistent" ];

  meta = {
    description = "Automatic persistence for Python objects";
    homepage = "https://github.com/zopefoundation/persistent/";
    changelog = "https://github.com/zopefoundation/persistent/blob/${version}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = [ ];
  };
}
