{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  click,
  # tests
  mock,
  prettytable,
  prompt-toolkit,
  pygments,
  pytestCheckHook,
  requests,
  rich,
  # build-system
  setuptools,
  sphinx,
  testtools,
  tkinter,
  urllib3,
  writableTmpDirAsHomeHook,
  zeep,
}:

buildPythonPackage rec {
  pname = "softlayer";
  version = "6.2.7";

  src = fetchFromGitHub {
    owner = "softlayer";
    repo = "softlayer-python";
    tag = "v${version}";
    hash = "sha256-mlC4o39Ol1ALguc9KGpxB0M0vhWz4LG2uwhW8CBrVgg=";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
    sphinx
    testtools
    tkinter
    writableTmpDirAsHomeHook
    zeep
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    click
    prettytable
    prompt-toolkit
    pygments
    requests
    rich
    urllib3
  ];

  disabledTestPaths = [
    # SoftLayer.exceptions.TransportError: TransportError(0): ('Connection aborted.', ConnectionResetError(54, 'Connection reset by peer'))
    "tests/CLI/modules/hardware/hardware_basic_tests.py::HardwareCLITests"

    # SystemExit: 1 (or 2)
    "tests/CLI/modules/hardware/hardware_list_tests.py::HardwareListCLITests"
    "tests/CLI/modules/vs/vs_create_tests.py::VirtCreateTests"
    "tests/CLI/modules/vs/vs_tests.py::VirtTests"

    # Test fails with ConnectionError trying to connect to api.softlayer.com
    "tests/transports/soap_tests.py.unstable"
  ];

  pyproject = true;
  pythonImportsCheck = [ "SoftLayer" ];
  pythonRelaxDeps = [ "rich" ];

  meta = {
    description = "Python libraries that assist in calling the SoftLayer API";
    homepage = "https://github.com/softlayer/softlayer-python";
    changelog = "https://github.com/softlayer/softlayer-python/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ onny ];
  };
}
