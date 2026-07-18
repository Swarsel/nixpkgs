{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "parts";
  version = "4.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-uw/bo+Y24KIgKH+hfc4iUboH8jJKeaoQGHBv6KjZixU=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "parts" ];

  meta = {
    description = "Library for common list functions related to partitioning lists";
    homepage = "https://github.com/lapets/parts";
    changelog = "https://github.com/lapets/parts/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
