{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "usb-devices";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "Bluetooth-Devices";
    repo = "usb-devices";
    tag = "v${version}";
    hash = "sha256-Nfdl5oRIdOfAo5PFAJJpadRyu2zeEkmYzxDQxbvpt6c=";
  };

  nativeBuildInputs = [ poetry-core ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  pyproject = true;
  pythonImportsCheck = [ "usb_devices" ];

  meta = {
    description = "Library for for mapping, describing, and resetting USB devices";
    homepage = "https://github.com/Bluetooth-Devices/usb-devices";
    changelog = "https://github.com/Bluetooth-Devices/usb-devices/blob/v${version}/CHANGELOG.md";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
