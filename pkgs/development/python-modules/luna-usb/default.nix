{
  lib,
  fetchFromGitHub,
  # dependencies
  amaranth,
  apollo-fpga,
  buildPythonPackage,
  libusb1,
  pyserial,
  # tests
  pytestCheckHook,
  pyusb,
  pyvcd,
  # build-system
  setuptools,
  usb-protocol,
}:
buildPythonPackage rec {
  pname = "luna-usb";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "greatscottgadgets";
    repo = "luna";
    tag = version;
    hash = "sha256-kH5PlgJRMymBZZ3oANR8xlAUPUgGZjqw9s9DcpQ809A=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"setuptools-git-versioning<2"' "" \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  nativeCheckInputs = [
    pytestCheckHook
    apollo-fpga
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    amaranth
    libusb1
    pyserial
    pyusb
    pyvcd
    usb-protocol
  ];

  enabledTestPaths = [
    "tests/"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "luna"
  ];

  meta = {
    description = "Amaranth HDL framework for monitoring, hacking, and developing USB devices";
    homepage = "https://github.com/greatscottgadgets/luna";
    changelog = "https://github.com/greatscottgadgets/luna/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ carlossless ];
  };
}
