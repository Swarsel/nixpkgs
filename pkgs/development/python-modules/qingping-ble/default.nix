{
  lib,
  fetchFromGitHub,
  bluetooth-data-tools,
  bluetooth-sensor-state-data,
  buildPythonPackage,
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
  sensor-state-data,
}:

buildPythonPackage (finalAttrs: {
  pname = "qingping-ble";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "bluetooth-devices";
    repo = "qingping-ble";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mUlOSagQADaHDiJkyFdEz3voh8a/zGb1RwqCI3PywYU=";
  };

  nativeCheckInputs = [
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
  pythonImportsCheck = [ "qingping_ble" ];

  meta = {
    description = "Library for Qingping BLE devices";
    homepage = "https://github.com/bluetooth-devices/qingping-ble";
    changelog = "https://github.com/Bluetooth-Devices/qingping-ble/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
