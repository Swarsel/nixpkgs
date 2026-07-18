{
  lib,
  fetchFromGitHub,
  # dependencies
  anyio,
  buildPythonPackage,
  # optional-dependencies
  channels,
  # build-system
  hatchling,
  # tests
  httpx-ws,
  hypercorn,
  pycrdt,
  pycrdt-store,
  pytest-asyncio,
  pytestCheckHook,
  sqlite-anyio,
  trio,
  uvicorn,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "pycrdt-websocket";
  version = "0.16.4";

  src = fetchFromGitHub {
    owner = "y-crdt";
    repo = "pycrdt-websocket";
    tag = finalAttrs.version;
    hash = "sha256-H9QxMxNCIvykGpdxNAtAbVpaJlpnq9O76nTh1raVfJU=";
  };

  nativeCheckInputs = [
    httpx-ws
    hypercorn
    pytest-asyncio
    pytestCheckHook
    trio
    uvicorn
    websockets
  ];

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    anyio
    pycrdt
    pycrdt-store
    sqlite-anyio
  ];

  disabledTestPaths = [
    # requires nodejs and installed js modules
    "tests/test_pycrdt_yjs.py"
  ];

  disabledTests = [
    # Looking for a certfile
    # FileNotFoundError: [Errno 2] No such file or directory
    "test_asgi"
    "test_yroom_restart"
  ];

  optional-dependencies = {
    django = [ channels ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pycrdt.websocket" ];

  meta = {
    description = "WebSocket Connector for pycrdt";
    homepage = "https://github.com/jupyter-server/pycrdt-websocket";
    changelog = "https://github.com/jupyter-server/pycrdt-websocket/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    teams = [ lib.teams.jupyter ];
  };
})
