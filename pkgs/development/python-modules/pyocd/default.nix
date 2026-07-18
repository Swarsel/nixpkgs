{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  capstone,
  cmsis-pack-manager,
  colorama,
  hidapi,
  importlib-metadata,
  importlib-resources,
  intelhex,
  intervaltree,
  lark,
  natsort,
  prettytable,
  pyelftools,
  pylink-square,
  # tests
  pytestCheckHook,
  pyusb,
  pyyaml,
  # build-system
  setuptools-scm,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pyocd";
  version = "0.42.0";

  src = fetchFromGitHub {
    owner = "pyocd";
    repo = "pyOCD";
    tag = "v${version}";
    hash = "sha256-VSEItt+mXiV3u3SAKQc8uGiJdT6b4nER/u6BwfaX2CM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];

  dependencies = [
    capstone
    cmsis-pack-manager
    colorama
    importlib-metadata
    importlib-resources
    intelhex
    intervaltree
    lark
    natsort
    prettytable
    pyelftools
    pylink-square
    pyusb
    pyyaml
    typing-extensions
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isLinux) [ hidapi ];

  disabledTests = [
    # AttributeError: 'not_called' is not a valid assertion
    # Upstream fix at https://github.com/pyocd/pyOCD/pull/1710
    "test_transfer_err_not_flushed"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyocd" ];
  pythonRelaxDeps = [ "capstone" ];
  pythonRemoveDeps = [ "libusb-package" ];

  meta = {
    description = "Python library for programming and debugging Arm Cortex-M microcontrollers";
    homepage = "https://pyocd.io";
    changelog = "https://github.com/pyocd/pyOCD/releases/tag/${src.tag}";
    license = lib.licenses.asl20;

    maintainers = [
    ];

    downloadPage = "https://github.com/pyocd/pyOCD";
  };
}
