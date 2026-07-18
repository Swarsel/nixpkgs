{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "namex";
  version = "0.1.0";

  # Not using fetchFromGitHub because the repo does not have any tag/release
  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-EX8DzNMCzEjj9cWKKWg49ricg0VauGg6HoXypDCqQwY=";
  };

  # No tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "namex" ];

  meta = {
    description = "Simple utility to separate the implementation of your Python package and its public API surface";
    homepage = "https://github.com/fchollet/namex";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
