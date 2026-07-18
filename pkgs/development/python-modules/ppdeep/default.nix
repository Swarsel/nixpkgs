{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "ppdeep";
  version = "20260221";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-i+H0Fkt60vfEClGmZNMXZwHkCy+cG5bRju/68G3+/5Q=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "ppdeep" ];

  meta = {
    description = "Python library for computing fuzzy hashes (ssdeep)";
    homepage = "https://github.com/elceef/ppdeep";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
