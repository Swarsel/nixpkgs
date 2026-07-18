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
  pname = "rapt-ble";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "sairon";
    repo = "rapt-ble";
    tag = "v${version}";
    hash = "sha256-ozZwVgTV/xYl1nXLiybcPs6DQKocNdbxTEYDfYyQuvY=";
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
  pythonImportsCheck = [ "rapt_ble" ];

  meta = {
    description = "Library for RAPT Pill hydrometer BLE devices";
    homepage = "https://github.com/sairon/rapt-ble";
    changelog = "https://github.com/sairon/rapt-ble/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
