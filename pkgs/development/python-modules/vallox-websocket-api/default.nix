{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  construct,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  websockets,
}:

buildPythonPackage rec {
  pname = "vallox-websocket-api";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "yozik04";
    repo = "vallox_websocket_api";
    tag = version;
    hash = "sha256-i4KUXvDz6FCdQguZtpNybyIPC/gn+O3SAYWh2CIbAeI=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    aiohttp
    construct
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "vallox_websocket_api" ];

  meta = {
    description = "Async API for Vallox ventilation units";
    homepage = "https://github.com/yozik04/vallox_websocket_api";
    changelog = "https://github.com/yozik04/vallox_websocket_api/releases/tag/${src.tag}";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
