{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "webio-api";
  version = "0.1.12";

  src = fetchPypi {
    inherit version;
    hash = "sha256-xS1uf407+ommERkZSYrElD6/tNXyBma3OFs4jUE5+tY=";
    pname = "webio_api";
  };

  # Package has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "webio_api" ];

  meta = {
    description = "Simple API to use for communication with WebIO device meant for Home Assistant integration";
    homepage = "https://github.com/nasWebio/webio_api";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
