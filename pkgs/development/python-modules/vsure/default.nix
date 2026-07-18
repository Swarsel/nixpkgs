{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "vsure";
  version = "2.8.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-FC2aRsfxBGO8HaEHGJWweKgZzz8UG/03oB/E+hOAe/w=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    click
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "verisure" ];

  meta = {
    description = "Python library for working with verisure devices";
    homepage = "https://github.com/persandstrom/python-verisure";
    changelog = "https://github.com/persandstrom/python-verisure#version-history";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "vsure";
  };
})
