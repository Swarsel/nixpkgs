{
  lib,
  fetchFromGitHub,
  bluetooth-data-tools,
  bluetooth-sensor-state-data,
  buildPythonPackage,
  hatchling,
  home-assistant-bluetooth,
  pytest-cov-stub,
  pytestCheckHook,
  sensor-state-data,
}:

buildPythonPackage (finalAttrs: {
  pname = "ruuvitag-ble";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "Bluetooth-Devices";
    repo = "ruuvitag-ble";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/xtNT36s7vdU0+1QFW2Of6v3OIQ9e6ZA9K3t9rPw5o8=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    bluetooth-data-tools
    bluetooth-sensor-state-data
    home-assistant-bluetooth
    sensor-state-data
  ];

  pyproject = true;
  pythonImportsCheck = [ "ruuvitag_ble" ];

  meta = {
    description = "Library for Ruuvitag BLE devices";
    homepage = "https://github.com/Bluetooth-Devices/ruuvitag-ble";
    changelog = "https://github.com/Bluetooth-Devices/ruuvitag-ble/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
