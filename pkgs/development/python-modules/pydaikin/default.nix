{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  freezegun,
  netifaces,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  tenacity,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "pydaikin";
  version = "2.18.1";

  src = fetchFromGitHub {
    owner = "fredrike";
    repo = "pydaikin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sTcdgbthDAyyWLxPtS344xR8a7UoN+zrfes6FXSo9g4=";
  };

  nativeCheckInputs = [
    aresponses
    freezegun
    pytest-asyncio
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    netifaces
    urllib3
    tenacity
  ];

  disabledTests = [
    # Failed: async def functions are not natively supported.
    "test_power_sensors"
    "test_device_factory"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pydaikin" ];

  meta = {
    description = "Python Daikin HVAC appliances interface";
    homepage = "https://github.com/fredrike/pydaikin";
    changelog = "https://github.com/fredrike/pydaikin/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "pydaikin";
  };
})
