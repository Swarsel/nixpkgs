{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  python-engineio-v3,
  requests,
  setuptools,
  six,
  websocket-client,
  websockets,
}:

buildPythonPackage rec {
  pname = "python-socketio-v4";
  version = "4.6.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-3VzLPYT4p4Uh2U4DMpxu6kq1NPZXlOqWOljLOe0bM40=";
  };

  # no tests on PyPI
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    python-engineio-v3
    six
  ];

  optional-dependencies = {
    asyncio_client = [
      aiohttp
      websockets
    ];

    client = [
      requests
      websocket-client
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "socketio_v4" ];

  meta = {
    description = "Socket.IO server";
    longDescription = "This is a release of 4.6.1 under the “socketio_v4” namespace for old systems.";
    homepage = "https://github.com/bdraco/python-socketio-v4";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
