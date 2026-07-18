{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  future,
  ipython,
  numpy,
  pyserial,
  pytestCheckHook,
  pyusb,
  udevCheckHook,
}:

buildPythonPackage rec {
  pname = "rfcat";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "atlas0fd00m";
    repo = "rfcat";
    tag = "v${version}";
    hash = "sha256-hdRsVbDXRC1EOhBoFJ9T5ZE6hwOgDWSdN5sIpxJ0x3E=";
  };

  nativeBuildInputs = [
    udevCheckHook
  ];

  propagatedBuildInputs = [
    future
    ipython
    numpy
    pyserial
    pyusb
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    mkdir -p $out/etc/udev/rules.d
    cp etc/udev/rules.d/20-rfcat.rules $out/etc/udev/rules.d
  '';

  format = "setuptools";
  pythonImportsCheck = [ "rflib" ];

  meta = {
    description = "Swiss Army knife of sub-GHz ISM band radio";
    homepage = "https://github.com/atlas0fd00m/rfcat";
    changelog = "https://github.com/atlas0fd00m/rfcat/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
