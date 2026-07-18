{
  lib,
  fetchFromGitHub,
  # dependencies
  amaranth,
  apollo-fpga,
  buildPythonPackage,
  libusb1,
  luna-soc,
  luna-usb,
  prompt-toolkit,
  pyfwup,
  pygreat,
  pyserial,
  # tests
  pytestCheckHook,
  pyusb,
  # build-system
  setuptools,
  tabulate,
  tomli,
  tqdm,
  udevCheckHook,
}:
buildPythonPackage rec {
  pname = "cynthion";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "greatscottgadgets";
    repo = "cynthion";
    tag = version;
    hash = "sha256-Ju01eqBVZ7CD0pw4nIFML4LcCPXzC78dLpQru3a+5bU=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"setuptools-git-versioning<2"' "" \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  nativeBuildInputs = [ udevCheckHook ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  # Make udev rules available for NixOS option services.udev.packages
  postInstall = ''
    install -Dm444 \
      -t $out/lib/udev/rules.d \
      build/lib/cynthion/assets/54-cynthion.rules
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    amaranth
    apollo-fpga
    libusb1
    luna-soc
    luna-usb
    prompt-toolkit
    pyfwup
    pygreat
    pyserial
    pyusb
    tabulate
    tomli
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "cynthion" ];
  pythonRelaxDeps = [ "pygreat" ];
  pythonRemoveDeps = [ "future" ];
  sourceRoot = "${src.name}/cynthion/python";

  meta = {
    description = "Python package and utilities for the Great Scott Gadgets Cynthion USB Test Instrument";
    homepage = "https://github.com/greatscottgadgets/cynthion";
    changelog = "https://github.com/greatscottgadgets/cynthion/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ carlossless ];
  };
}
