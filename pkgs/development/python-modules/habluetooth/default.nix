{
  lib,
  fetchFromGitHub,
  async-interrupt,
  bleak,
  bleak-retry-connector,
  bluetooth-adapters,
  bluetooth-auto-recovery,
  bluetooth-data-tools,
  buildPythonPackage,
  cython,
  freezegun,
  poetry-core,
  pytest-asyncio,
  pytest-codspeed,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "habluetooth";
  version = "6.26.5";

  src = fetchFromGitHub {
    owner = "Bluetooth-Devices";
    repo = "habluetooth";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IM3M4fWTdD4wT3UsNiLZq7QX3p9pf+lR3x84vuOICMM=";
  };

  nativeCheckInputs = [
    freezegun
    pytest-asyncio
    pytest-codspeed
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    cython
    poetry-core
    setuptools
  ];

  dependencies = [
    async-interrupt
    bleak
    bleak-retry-connector
    bluetooth-adapters
    bluetooth-auto-recovery
    bluetooth-data-tools
  ];

  pyproject = true;
  pythonImportsCheck = [ "habluetooth" ];

  meta = {
    description = "Library for high availability Bluetooth";
    homepage = "https://github.com/Bluetooth-Devices/habluetooth";
    changelog = "https://github.com/Bluetooth-Devices/habluetooth/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
