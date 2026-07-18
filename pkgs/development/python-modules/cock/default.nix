{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
  pyyaml,
  setuptools,
  sortedcontainers,
}:

buildPythonPackage (finalAttrs: {
  pname = "cock";
  version = "0.11.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Hi8aFxATsYcEO6qNzZnF73V8WLTQjb6Dw2xF4VgT2o4=";
  };

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    click
    sortedcontainers
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "cock" ];

  meta = {
    description = "Configuration file with click";
    homepage = "https://github.com/pohmelie/cock";
    license = lib.licenses.mit;
  };
})
