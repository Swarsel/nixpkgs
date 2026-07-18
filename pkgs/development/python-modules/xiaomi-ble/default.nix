{
  lib,
  fetchFromGitHub,
  bleak,
  bleak-retry-connector,
  bluetooth-data-tools,
  bluetooth-sensor-state-data,
  buildPythonPackage,
  cryptography,
  home-assistant-bluetooth,
  orjson,
  poetry-core,
  pycryptodomex,
  pytest-cov-stub,
  pytestCheckHook,
  sensor-state-data,
}:

buildPythonPackage (finalAttrs: {
  pname = "xiaomi-ble";
  version = "1.15.0";

  src = fetchFromGitHub {
    owner = "Bluetooth-Devices";
    repo = "xiaomi-ble";
    tag = "v${finalAttrs.version}";
    hash = "sha256-I0Lifki39TLbtnITADtmPygwKq11sugTDdveqpLQ/n0=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    bleak
    bleak-retry-connector
    bluetooth-data-tools
    bluetooth-sensor-state-data
    cryptography
    home-assistant-bluetooth
    orjson
    pycryptodomex
    sensor-state-data
  ];

  pyproject = true;
  pythonImportsCheck = [ "xiaomi_ble" ];
  pythonRelaxDeps = [ "pycryptodomex" ];

  meta = {
    description = "Library for Xiaomi BLE devices";
    homepage = "https://github.com/Bluetooth-Devices/xiaomi-ble";
    changelog = "https://github.com/Bluetooth-Devices/xiaomi-ble/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
