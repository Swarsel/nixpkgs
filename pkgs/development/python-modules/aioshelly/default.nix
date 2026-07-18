{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  bleak-retry-connector,
  bluetooth-data-tools,
  buildPythonPackage,
  habluetooth,
  orjson,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  yarl,
  zeroconf,
}:

buildPythonPackage (finalAttrs: {
  pname = "aioshelly";
  version = "13.26.2";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "aioshelly";
    tag = finalAttrs.version;
    hash = "sha256-LNMFFi3afbDFezr32zr85lNX1TIdo8BF04yDfc2AIA0=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    bleak-retry-connector
    bluetooth-data-tools
    habluetooth
    orjson
    yarl
    zeroconf
  ];

  pyproject = true;
  pythonImportsCheck = [ "aioshelly" ];

  meta = {
    description = "Python library to control Shelly";
    homepage = "https://github.com/home-assistant-libs/aioshelly";
    changelog = "https://github.com/home-assistant-libs/aioshelly/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
