{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "multitasking";
  version = "0.0.13";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-2Ja134d8nKXu3b8OWZQSRpTWy1NaummPsjNExwJRVaE=";
  };

  doCheck = false; # No tests included
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "multitasking" ];

  meta = {
    description = "Non-blocking Python methods using decorators";
    homepage = "https://github.com/ranaroussi/multitasking";
    changelog = "https://github.com/ranaroussi/multitasking/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
