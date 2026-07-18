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
  pname = "bluemaestro-ble";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Bluetooth-Devices";
    repo = "bluemaestro-ble";
    tag = "v${version}";
    hash = "sha256-H7VAidnClMA/Qmc4ahzrmSaqkWj50zMjfakRD0wX8xM=";
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
  pythonImportsCheck = [ "bluemaestro_ble" ];

  meta = {
    description = "Library for bluemaestro BLE devices";
    homepage = "https://github.com/Bluetooth-Devices/bluemaestro-ble";
    changelog = "https://github.com/Bluetooth-Devices/bluemaestro-ble/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
