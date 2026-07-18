{
  lib,
  fetchFromGitHub,
  # dependencies
  appdirs,
  buildPythonPackage,
  intelhex,
  # tests
  mock,
  parameterized,
  pyedbglib,
  pyserial,
  pytestCheckHook,
  pyyaml,
  # build-system
  setuptools,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pymcuprog";
  version = "3.19.4.61";

  src = fetchFromGitHub {
    owner = "microchip-pic-avr-tools";
    repo = "pymcuprog";
    tag = finalAttrs.version;
    hash = "sha256-RmFGQ6LbuwwM/WHr01nYGZYoWG7Qbasz/TL4r8l1NUk";
  };

  nativeCheckInputs = [
    mock
    parameterized
    pytestCheckHook
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    appdirs
    intelhex
    pyedbglib
    pyserial
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "pymcuprog" ];
  versionCheckKeepEnvironment = "HOME";

  meta = {
    description = "Python utility for programming various Microchip MCU devices using Microchip CMSIS-DAP based debuggers";
    homepage = "https://github.com/microchip-pic-avr-tools/pymcuprog";
    changelog = "https://github.com/microchip-pic-avr-tools/pymcuprog/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prophetofxenu ];
    mainProgram = "pymcuprog";
  };
})
