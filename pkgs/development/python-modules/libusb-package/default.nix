{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  libusb1,
  pyusb,
  replaceVars,
  setuptools,
  setuptools-scm,
  tomli,
}:

buildPythonPackage rec {
  pname = "libusb-package";
  version = "1.0.26.3";

  src = fetchFromGitHub {
    owner = "pyocd";
    repo = "libusb-package";
    tag = "v${version}";
    hash = "sha256-4zTyaidpSlledTcEztWzRgwj43oNV7xWrhMXCE9Qz3k=";
  };

  patches = [
    (replaceVars ./hardcode-libusb1-path.patch {
      libusb1 = "${lib.getLib libusb1}/lib/libusb-1.0${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
  ];

  nativeCheckInputs = [
    pyusb
  ];

  checkPhase = ''
    runHook preCheck

    python test.py

    runHook postCheck
  '';

  build-system = [
    setuptools
    setuptools-scm
    tomli
  ];

  pyproject = true;

  meta = {
    description = "Python package for simplified libusb distribution and usage with pyOCD";
    homepage = "https://github.com/pyocd/libusb-package";
    changelog = "https://github.com/pyocd/libusb-package/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.brianmcgillion ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
