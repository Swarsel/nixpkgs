{
  lib,
  aiohttp,
  buildPythonPackage,
  certifi,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "crownstone-sse";
  version = "2.0.5";

  src = fetchPypi {
    inherit version;
    hash = "sha256-RUqo68UAVGV+JmauKsGlp7dG8FzixHBDnr3eho/IQdY=";
    pname = "crownstone_sse";
  };

  # Tests are only providing coverage
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    certifi
  ];

  pyproject = true;
  pythonImportsCheck = [ "crownstone_sse" ];

  meta = {
    description = "Python module for listening to Crownstone SSE events";
    homepage = "https://github.com/Crownstone-Community/crownstone-lib-python-sse";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
