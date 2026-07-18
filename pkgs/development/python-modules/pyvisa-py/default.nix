{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gpib-ctypes,
  psutil,
  pyserial,
  pytestCheckHook,
  pyusb,
  pyvisa,
  setuptools,
  setuptools-scm,
  typing-extensions,
  zeroconf,
}:

buildPythonPackage rec {
  pname = "pyvisa-py";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "pyvisa";
    repo = "pyvisa-py";
    tag = version;
    hash = "sha256-fXLT3W48HQ744LkwZn784KKmUE8gxDCR+lkcL9xX45g=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    pyvisa
    typing-extensions
  ];

  optional-dependencies = {
    gpib-ctypes = [ gpib-ctypes ];
    hislip-discovery = [ zeroconf ];
    psutil = [ psutil ];
    serial = [ pyserial ];
    usb = [ pyusb ];
    # vicp = [ pyvicp zeroconf ];
  };

  pyproject = true;

  meta = {
    description = "Module that implements the Virtual Instrument Software Architecture";
    homepage = "https://github.com/pyvisa/pyvisa-py";
    changelog = "https://github.com/pyvisa/pyvisa-py/blob/${src.tag}/CHANGES";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mvnetbiz ];
  };
}
