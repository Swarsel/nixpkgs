{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
  pytz,
  victron-mqtt,
}:

buildPythonPackage rec {
  pname = "victron-vrm";
  version = "0.1.12";

  src = fetchFromGitHub {
    owner = "KSoft-Si";
    repo = "vrm-client";
    tag = "v${version}";
    hash = "sha256-In4yL5e6DZkP/8JeM1FhoMuhsqQ6uZE3fFLyfnLzgZQ=";
  };

  # tests connect to vrmapi.victronenergy.com
  doCheck = false;

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    pydantic
    pytz
    victron-mqtt
  ];

  pyproject = true;
  pythonImportsCheck = [ "victron_vrm" ];
  pythonRelaxDeps = [ "victron-mqtt" ];

  meta = {
    description = "Async Python client for the Victron Energy VRM API";
    homepage = "https://github.com/KSoft-Si/vrm-client";
    changelog = "https://github.com/KSoft-Si/vrm-client/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
