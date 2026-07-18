{
  lib,
  stdenv,
  buildPythonPackage,
  cython,
  fetchPypi,
  hidapi,
  libusb1,
  pkg-config,
  setuptools,
  udev,
  xcbuild,
}:

buildPythonPackage rec {
  pname = "hidapi";
  version = "0.15.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-7LwmXL6Le4h1X0IeC6JfCECR7FUMK5D/no3dT81UAxE=";
  };

  nativeBuildInputs = [ pkg-config ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ xcbuild ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    hidapi
    libusb1
  ];

  propagatedBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ udev ];

  env = lib.optionalAttrs stdenv.hostPlatform.isLinux {
    HIDAPI_SYSTEM_HIDAPI = true;
  };

  build-system = [
    cython
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "hid" ];

  meta = {
    description = "Cython interface to the hidapi from https://github.com/libusb/hidapi";
    homepage = "https://github.com/trezor/cython-hidapi";

    # license can actually be either bsd3 or gpl3
    # see https://github.com/trezor/cython-hidapi/blob/master/LICENSE-orig.txt
    license = with lib.licenses; [
      bsd3
      gpl3Only
    ];

    maintainers = with lib.maintainers; [
      np
      prusnak
    ];
  };
}
