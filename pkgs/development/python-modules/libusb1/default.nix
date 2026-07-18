{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  libusb1,
  pytestCheckHook,
  replaceVars,
  setuptools,
}:

buildPythonPackage rec {
  pname = "libusb1";
  version = "3.3.1";

  src = fetchFromGitHub {
    owner = "vpelletier";
    repo = "python-libusb1";
    tag = version;
    hash = "sha256-nytxew6KogpEpSnRtmY0UNH+07x0k0XLZ/MRC9NSpDg=";
  };

  patches = [
    (replaceVars ./ctypes.patch {
      libusb = "${lib.getLib libusb1}/lib/libusb-1.0${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
  ];

  buildInputs = [ libusb1 ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  enabledTestPaths = [ "usb1/testUSB1.py" ];
  pyproject = true;

  meta = {
    description = "Python ctype-based wrapper around libusb1";
    homepage = "https://github.com/vpelletier/python-libusb1";
    license = lib.licenses.lgpl2Plus;

    maintainers = with lib.maintainers; [
      prusnak
      rnhmjoj
    ];
  };
}
