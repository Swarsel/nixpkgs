{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  pytest-asyncio,
  pytestCheckHook,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-opendata-transport";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "home-assistant-ecosystem";
    repo = "python-opendata-transport";
    tag = finalAttrs.version;
    hash = "sha256-CN+zy2x+4IKdAcpa2vIrOGXW39d+anU4HGPU83dGif0=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "opendata_transport" ];

  meta = {
    description = "Python client for interacting with transport.opendata.ch";
    homepage = "https://github.com/home-assistant-ecosystem/python-opendata-transport";
    changelog = "https://github.com/home-assistant-ecosystem/python-opendata-transport/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
