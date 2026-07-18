{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "sensor-state-data";
  version = "2.20.0";

  src = fetchFromGitHub {
    owner = "Bluetooth-Devices";
    repo = "sensor-state-data";
    tag = "v${version}";
    hash = "sha256-ONAM1WxKnzRCJsuJa+4zDaOXPkTj+zcTH54SgktpMR8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "sensor_state_data" ];

  meta = {
    description = "Models for storing and converting Sensor Data state";
    homepage = "https://github.com/bluetooth-devices/sensor-state-data";
    changelog = "https://github.com/Bluetooth-Devices/sensor-state-data/releases/tag/${src.tag}";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
