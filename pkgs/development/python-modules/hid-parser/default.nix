{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  hypothesis,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "hid-parser";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "usb-tools";
    repo = "python-hid-parser";
    tag = version;
    hash = "sha256-8aGyLTsBK5etwbqFkNinbLHCt20fsQEmuBvu3RrwCDA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
  ];

  build-system = [ flit-core ];
  pyproject = true;
  pythonImportsCheck = [ "hid_parser" ];

  meta = {
    description = "Typed pure Python library to parse HID report descriptors";
    homepage = "https://github.com/usb-tools/python-hid-parser";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
