{
  lib,
  fetchFromGitHub,
  asyncinotify,
  buildPythonPackage,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aiousbwatcher";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "Bluetooth-Devices";
    repo = "aiousbwatcher";
    tag = "v${version}";
    hash = "sha256-kCuY4+pdfnO8BuYSQjZEyGxSaCwVYXRHWYhnbzxlDzM=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ asyncinotify ];
  pyproject = true;
  pythonImportsCheck = [ "aiousbwatcher" ];

  meta = {
    description = "Watch for USB devices to be plugged and unplugged";
    homepage = "https://github.com/Bluetooth-Devices/aiousbwatcher";
    changelog = "https://github.com/Bluetooth-Devices/aiousbwatcher/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
