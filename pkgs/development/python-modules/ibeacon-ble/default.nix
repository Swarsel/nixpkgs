{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiooui,
  buildPythonPackage,
  home-assistant-bluetooth,
  mac-vendor-lookup,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "ibeacon-ble";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "Bluetooth-Devices";
    repo = "ibeacon-ble";
    tag = "v${version}";
    hash = "sha256-1liSWxduYpjIMu7226EH4bsc7gca5g/fyL79W4ZMdU4=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    aiooui
    home-assistant-bluetooth
    mac-vendor-lookup
  ];

  pyproject = true;
  pythonImportsCheck = [ "ibeacon_ble" ];

  meta = {
    description = "Library for iBeacon BLE devices";
    homepage = "https://github.com/Bluetooth-Devices/ibeacon-ble";
    changelog = "https://github.com/Bluetooth-Devices/ibeacon-ble/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
