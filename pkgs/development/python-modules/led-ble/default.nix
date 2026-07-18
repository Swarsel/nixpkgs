{
  lib,
  fetchFromGitHub,
  bleak,
  bleak-retry-connector,
  buildPythonPackage,
  flux-led,
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "led-ble";
  version = "1.1.11";

  src = fetchFromGitHub {
    owner = "Bluetooth-Devices";
    repo = "led-ble";
    tag = "v${version}";
    hash = "sha256-YPOjbmHR6WpmAEpYFl/ajzojgiIYEk+6H5LFjl1yo1c=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    bleak
    bleak-retry-connector
    flux-led
  ];

  pyproject = true;
  pythonImportsCheck = [ "led_ble" ];

  meta = {
    description = "Library for LED BLE devices";
    homepage = "https://github.com/Bluetooth-Devices/led-ble";
    changelog = "https://github.com/Bluetooth-Devices/led-ble/blob/v${version}/CHANGELOG.md";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
