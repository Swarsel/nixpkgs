{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  pyusb,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-yubico";
  version = "1.3.3";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-2EZkJ6pZIqxdS36cZbaTEIQnz1N9ZT1oyyEsBxPo5vU=";
  };

  checkInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ pyusb ];

  disabledTests = [
    "usb" # requires a physical yubikey to test
  ];

  pyproject = true;
  pythonImportsCheck = [ "yubico" ];

  meta = {
    description = "Python code to talk to YubiKeys";
    homepage = "https://github.com/Yubico/python-yubico";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ s1341 ];
  };
})
