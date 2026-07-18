{
  lib,
  stdenv,
  fetchFromGitHub,
  # optional-dependencies
  aiohttp,
  # dependencies
  bidict,
  buildPythonPackage,
  # tests
  msgpack,
  pytest-asyncio,
  pytestCheckHook,
  python-engineio,
  redis,
  requests,
  # build-system
  setuptools,
  simple-websocket,
  uvicorn,
  valkey,
  websocket-client,
}:

buildPythonPackage rec {
  pname = "python-socketio";
  version = "5.16.3";

  src = fetchFromGitHub {
    owner = "miguelgrinberg";
    repo = "python-socketio";
    tag = "v${version}";
    hash = "sha256-ma17XN4LHPte/Df0z83olzcSKwOsKX9l0BHTdrv2XJ0=";
  };

  nativeCheckInputs = [
    msgpack
    pytestCheckHook
    uvicorn
    simple-websocket
    redis
    valkey
    pytest-asyncio
  ]
  ++ lib.concatAttrValues optional-dependencies;

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    bidict
    python-engineio
  ];

  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [
    # Use fixed ports which leads to failures when building concurrently
    "tests/async/test_admin.py"
    "tests/common/test_admin.py"
  ];

  optional-dependencies = {
    asyncio_client = [ aiohttp ];

    client = [
      requests
      websocket-client
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "socketio" ];

  meta = {
    description = "Python Socket.IO server and client";

    longDescription = ''
      Socket.IO is a lightweight transport protocol that enables real-time
      bidirectional event-based communication between clients and a server.
    '';

    homepage = "https://github.com/miguelgrinberg/python-socketio/";
    changelog = "https://github.com/miguelgrinberg/python-socketio/blob/${src.tag}/CHANGES.md";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ mic92 ];
  };
}
