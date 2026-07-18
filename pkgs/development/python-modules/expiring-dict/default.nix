{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  sortedcontainers,
}:

buildPythonPackage rec {
  pname = "expiring-dict";
  version = "1.1.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-yoy4AjBOrlszoj7EwZAZthCt/aUMvEyb+jrVws04djE=";
    pname = "expiring_dict";
  };

  build-system = [ setuptools ];
  dependencies = [ sortedcontainers ];
  pyproject = true;
  pythonImportsCheck = [ "expiring_dict" ];

  meta = {
    description = "Python dict with TTL support for auto-expiring caches";
    homepage = "https://github.com/dparker2/py-expiring-dict";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
