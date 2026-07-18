{
  lib,
  aiohttp,
  backoff,
  buildPythonPackage,
  fetchPypi,
  importlib-metadata,
  poetry-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "pypoolstation";
  version = "0.6.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-blTvbvuIS2YISd0jBR/TXOSm594htGB7lc9JpA+3ayM=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    backoff
    importlib-metadata
  ];

  pyproject = true;
  pythonImportsCheck = [ "pypoolstation" ];

  meta = {
    description = "Python library to interact the the Poolstation platform";
    homepage = "https://github.com/cibernox/PyPoolstation";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
