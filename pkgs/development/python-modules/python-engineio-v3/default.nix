{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
  six,
  websocket-client,
}:

buildPythonPackage rec {
  pname = "python-engineio-v3";
  version = "3.14.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-tYri/+OKIJAWWzeijFwgY9PK66lH584dvZnoBWyzaFw=";
  };

  # no tests on PyPI
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ six ];

  optional-dependencies = {
    asyncio_client = [ aiohttp ];

    client = [
      requests
      websocket-client
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "engineio_v3" ];

  meta = {
    description = "Engine.IO server";
    longDescription = "This is a release of 3.14.2 under the “engineio_v3” namespace for old systems.";
    homepage = "https://github.com/bdraco/python-engineio-v3";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
