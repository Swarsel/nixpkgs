{
  lib,
  fetchFromGitHub,
  bluetooth-data-tools,
  bluetooth-sensor-state-data,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  sensor-state-data,
}:

buildPythonPackage (finalAttrs: {
  pname = "thermopro-ble";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "bluetooth-devices";
    repo = "thermopro-ble";
    tag = "v${finalAttrs.version}";
    hash = "sha256-goTJwTMaWBm5gc0/LOkjpKeRTkLStHkKJYsbE5Wj/X4=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    bluetooth-data-tools
    bluetooth-sensor-state-data
    sensor-state-data
  ];

  pyproject = true;
  pythonImportsCheck = [ "thermopro_ble" ];

  meta = {
    description = "Library for Thermopro BLE devices";
    homepage = "https://github.com/bluetooth-devices/thermopro-ble";
    changelog = "https://github.com/Bluetooth-Devices/thermopro-ble/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
