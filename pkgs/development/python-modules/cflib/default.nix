{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  libusb-package,
  numpy,
  packaging,
  pytestCheckHook,
  pyusb,
  pyyaml,
  scipy,
  setuptools,
  setuptools-scm,
  udevCheckHook,
}:

buildPythonPackage rec {
  pname = "cflib";
  version = "0.1.31";

  src = fetchFromGitHub {
    owner = "bitcraze";
    repo = "crazyflie-lib-python";
    tag = version;
    hash = "sha256-PYAkN52dx1qeRKoe5FwpKj1A4oJNYb7Dx8vko9Pwspw=";
  };

  strictDeps = true;

  nativeCheckInputs = [
    pytestCheckHook
    pyyaml
  ];

  # Install udev rules as defined
  # https://www.bitcraze.io/documentation/repository/crazyflie-lib-python/master/installation/usb_permissions/
  postInstall = ''
    # Install udev rules
    mkdir -p $out/etc/udev/rules.d

    cat <<EOF > $out/etc/udev/rules.d/99-bitcraze.rules
    # Crazyradio (normal operation)
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1915", ATTRS{idProduct}=="7777", MODE="0664", GROUP="plugdev"
    # Bootloader
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1915", ATTRS{idProduct}=="0101", MODE="0664", GROUP="plugdev"
    # Crazyflie (over USB)
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5740", MODE="0664", GROUP="plugdev"
    EOF
  '';

  # The udevCheckHook is used to verify udev rules
  # requires diInstallCheck to be enabled, which is default for pythonPackages
  nativeInstallCheckInputs = [
    udevCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    libusb-package
    numpy
    packaging
    pyusb
    scipy
  ];

  disabledTestPaths = [
    # exception: Cannot find a Crazyradio Dongle (HW required)
    "examples/radio/radio_test.py"
    "sys_test/single_cf_grounded/"
    "sys_test/swarm_test_rig/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "cflib" ];

  pythonRelaxDeps = [
    "numpy"
    "packaging"
  ];

  meta = {
    description = "Python library for the Crazyflie quadcopter by Bitcraze";
    homepage = "https://github.com/bitcraze/crazyflie-lib-python";
    changelog = "https://github.com/bitcraze/crazyflie-lib-python/releases/tag/${src.tag}";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.brianmcgillion ];
    platforms = lib.platforms.linux;
  };
}
