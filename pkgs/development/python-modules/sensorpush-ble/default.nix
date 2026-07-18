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
  pname = "sensorpush-ble";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "Bluetooth-Devices";
    repo = "sensorpush-ble";
    tag = "v${version}";
    hash = "sha256-Jsf/NTVwEHoH989yQqWEdG43H74JHlKpUvMWuH4paOw=";
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
  pythonImportsCheck = [ "sensorpush_ble" ];

  meta = {
    description = "Library for SensorPush BLE devices";
    homepage = "https://github.com/Bluetooth-Devices/sensorpush-ble";
    changelog = "https://github.com/Bluetooth-Devices/sensorpush-ble/releases/tag/v${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
