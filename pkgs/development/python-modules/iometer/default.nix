{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiohttp-sse-client,
  aioresponses,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
  yarl,
}:

buildPythonPackage (finalAttrs: {
  pname = "iometer";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "iometer-gmbh";
    repo = "iometer.py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-50tq+z1+8CX58Yj6GztYXStHMG+IncOHDgwK8WhxVcQ=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    aiohttp-sse-client
    yarl
  ];

  enabledTestPaths = [
    "tests/test.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "iometer" ];

  meta = {
    description = "Python client for interacting with IOmeter devices over HTTP";
    homepage = "https://github.com/iometer-gmbh/iometer.py";
    changelog = "https://github.com/iometer-gmbh/iometer.py/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
