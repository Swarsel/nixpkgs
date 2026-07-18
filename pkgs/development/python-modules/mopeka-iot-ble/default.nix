{
  lib,
  fetchFromGitHub,
  bluetooth-data-tools,
  bluetooth-sensor-state-data,
  buildPythonPackage,
  home-assistant-bluetooth,
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
  sensor-state-data,
}:

buildPythonPackage rec {
  pname = "mopeka-iot-ble";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "bluetooth-devices";
    repo = "mopeka-iot-ble";
    tag = "v${version}";
    hash = "sha256-CKLC0p66JapE9qNePE11ttoGMVd4kA7g28kA+pYLXCE=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    bluetooth-data-tools
    bluetooth-sensor-state-data
    home-assistant-bluetooth
    sensor-state-data
  ];

  pyproject = true;
  pythonImportsCheck = [ "mopeka_iot_ble" ];

  meta = {
    description = "Library for Mopeka IoT BLE devices";
    homepage = "https://github.com/bluetooth-devices/mopeka-iot-ble";
    changelog = "https://github.com/Bluetooth-Devices/mopeka-iot-ble/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
