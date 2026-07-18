{
  lib,
  fetchFromGitHub,
  bluetooth-sensor-state-data,
  buildPythonPackage,
  poetry-core,
  pycryptodomex,
  pytest-cov-stub,
  pytestCheckHook,
  sensor-state-data,
}:

buildPythonPackage rec {
  pname = "atc-ble";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "Bluetooth-Devices";
    repo = "atc-ble";
    tag = "v${version}";
    hash = "sha256-rwOFKxUlbbNIDJRdCmZpHstXwxcTnvlExgcVDdGbIVY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ poetry-core ];

  dependencies = [
    bluetooth-sensor-state-data
    pycryptodomex
    sensor-state-data
  ];

  pyproject = true;
  pythonImportsCheck = [ "atc_ble" ];

  meta = {
    description = "Library for ATC devices with custom firmware";
    homepage = "https://github.com/Bluetooth-Devices/atc-ble";
    changelog = "https://github.com/Bluetooth-Devices/atc-ble/releases/tag/v${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
