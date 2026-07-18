{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  cython,
  hidapi,
  mock,
  pyserial,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyedbglib";
  version = "2.24.2.18";

  src = fetchFromGitHub {
    owner = "microchip-pic-avr-tools";
    repo = "pyedbglib";
    tag = finalAttrs.version;
    hash = "sha256-iZB/+JEBy5n1zfajmJmEqRVQ2hPzJD/U85SvmyFiGhc=";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    cython
    hidapi
    pyserial
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyedbglib" ];

  meta = {
    description = "Low-level protocol library for communicating with Microchip CMSIS-DAP based debuggers";
    homepage = "https://github.com/microchip-pic-avr-tools/pyedbglib";
    changelog = "https://github.com/microchip-pic-avr-tools/pyedbglib/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prophetofxenu ];
  };
})
