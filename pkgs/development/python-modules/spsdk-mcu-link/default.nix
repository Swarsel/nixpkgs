{
  lib,
  buildPythonPackage,
  # tests
  click,
  fetchPypi,
  # dependencies
  hidapi,
  pytestCheckHook,
  pyusb,
  # build-system
  setuptools,
  spsdk,
  # passthru
  spsdk-mcu-link,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "spsdk-mcu-link";
  version = "0.6.6";

  # Latest tag missing on GitHub
  src = fetchPypi {
    inherit version;
    hash = "sha256-KISqhJJFtHFCDOFs+Zx0ghX0lGK5tazVqEIOT9gyAQs=";
    pname = "spsdk_mcu_link";
  };

  # Cyclic dependency with spsdk
  doCheck = false;

  nativeCheckInputs = [
    click
    pytestCheckHook
    spsdk
    writableTmpDirAsHomeHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    hidapi
    pyusb
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "hidapi"
    "pyusb"
  ];

  pythonRemoveDeps = [
    # unpackaged
    "libusb_package"
    "wasmtime"
  ];

  passthru.tests = {
    pytest = spsdk-mcu-link.overridePythonAttrs {
      doCheck = true;

      pythonImportsCheck = [
        "spsdk_mcu_link"
      ];
    };
  };

  meta = {
    description = "Debugger probe plugin for SPSDK supporting LPC-Link/MCU-Link from NXP";
    homepage = "https://pypi.org/project/spsdk-mcu-link";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
