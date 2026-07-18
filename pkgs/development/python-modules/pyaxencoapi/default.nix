{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  python-socketio,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyaxencoapi";
  version = "1.0.7";

  src = fetchFromGitHub {
    owner = "AXENCO-FR";
    repo = "ha-py-axenco-api";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ml58+kstIpqQUXDt/jpZeR8ueu5U3nnH7hiUcZxveAM=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    python-socketio
  ]
  ++ python-socketio.optional-dependencies.asyncio_client;

  pyproject = true;
  pythonImportsCheck = [ "pyaxencoapi" ];

  meta = {
    description = "Async Python client for Axenco MyNeomitis REST/Websocket API";
    homepage = "https://github.com/AXENCO-FR/ha-py-axenco-api";
    changelog = "https://github.com/AXENCO-FR/ha-py-axenco-api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
