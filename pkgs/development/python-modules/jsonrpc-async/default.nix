{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  jsonrpc-base,
  pytest-aiohttp,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "jsonrpc-async";
  version = "2.1.3";

  src = fetchFromGitHub {
    owner = "emlove";
    repo = "jsonrpc-async";
    tag = version;
    hash = "sha256-WcO2mj5QYZTMnFTNo1ABgpJPxM+GREVIf+z9viFDJHM=";
  };

  nativeCheckInputs = [
    pytest-aiohttp
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    jsonrpc-base
  ];

  enabledTestPaths = [ "tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "jsonrpc_async" ];

  meta = {
    description = "JSON-RPC client library for asyncio";
    homepage = "https://github.com/emlove/jsonrpc-async";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ peterhoeg ];
  };
}
