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
  pname = "leaone-ble";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "bluetooth-devices";
    repo = "leaone-ble";
    tag = "v${version}";
    hash = "sha256-WdsAqXv3U2E5x6Io4t3NNcioV6kwREDATe4hpojzUBo=";
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
  pythonImportsCheck = [ "leaone_ble" ];

  meta = {
    description = "Bluetooth parser for LeaOne devices";
    homepage = "https://github.com/bluetooth-devices/leaone-ble";
    changelog = "https://github.com/bluetooth-devices/leaone-ble/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
