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

buildPythonPackage rec {
  pname = "thermobeacon-ble";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "bluetooth-devices";
    repo = "thermobeacon-ble";
    tag = "v${version}";
    hash = "sha256-ij8g1bq9xmHLSHf2O69H6laK+KsEmW7E+hXv52/iJkY=";
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
  pythonImportsCheck = [ "thermobeacon_ble" ];

  meta = {
    description = "Library for Thermobeacon BLE devices";
    homepage = "https://github.com/bluetooth-devices/thermobeacon-ble";
    changelog = "https://github.com/Bluetooth-Devices/thermobeacon-ble/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
