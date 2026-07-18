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
  pname = "sensorpro-ble";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Bluetooth-Devices";
    repo = "sensorpro-ble";
    tag = "v${version}";
    hash = "sha256-DsISsczQCGtLc15VJrZvggDZDmYNuEKkabrAHcDZmWE=";
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
  pythonImportsCheck = [ "sensorpro_ble" ];

  meta = {
    description = "Library for Sensorpro BLE devices";
    homepage = "https://github.com/Bluetooth-Devices/sensorpro-ble";
    changelog = "https://github.com/Bluetooth-Devices/sensorpro-ble/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
