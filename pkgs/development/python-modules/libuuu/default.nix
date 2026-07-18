{
  lib,
  stdenv,
  autoPatchelfHook,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  udev,
}:

buildPythonPackage rec {
  pname = "libuuu";
  version = "1.5.243";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-k7DFVrqkHzPLjZMdWyLdfawyOSw+L7Bi4oRdeJo6lxw=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    udev
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  # Prevent tests to load the plugin from the source files instead of the installed ones
  preCheck = ''
    rm -rf libuuu
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    setuptools-scm
  ];

  pyproject = true;

  pythonImportsCheck = [
    "libuuu"
  ];

  pythonRelaxDeps = [
    "setuptools-scm"
  ];

  meta = {
    description = "Python wrapper for libuuu";
    homepage = "https://github.com/nxp-imx/mfgtools/tree/master/wrapper";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
