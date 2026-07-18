{
  lib,
  fetchFromGitHub,
  bleak,
  bleak-retry-connector,
  bluetooth-data-tools,
  bluetooth-sensor-state-data,
  buildPythonPackage,
  home-assistant-bluetooth,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "oralb-ble";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "Bluetooth-Devices";
    repo = "oralb-ble";
    tag = "v${version}";
    hash = "sha256-XAfeJLM4Uw/sEbDhXcNuyHV/m4k9DlIwFt+gP8DsgJ4=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    bleak
    bleak-retry-connector
    bluetooth-data-tools
    bluetooth-sensor-state-data
    home-assistant-bluetooth
  ];

  disabledTests = [
    # Test is outdated, TypeError: BLEDevice.__init__() missing 2 required...
    "test_async_poll"
  ];

  pyproject = true;
  pythonImportsCheck = [ "oralb_ble" ];

  meta = {
    description = "Library for Oral B BLE devices";
    homepage = "https://github.com/Bluetooth-Devices/oralb-ble";
    changelog = "https://github.com/Bluetooth-Devices/oralb-ble/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
