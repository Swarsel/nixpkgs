{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pyserial,
  pytestCheckHook,
  rich,
}:

buildPythonPackage rec {
  pname = "numato-gpio";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "clssn";
    repo = "numato-gpio";
    tag = "v${version}";
    hash = "sha256-9kbPEtJOQhCxYh8cjyCAufV63mV7ZF1x7CdUyJLfqII=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    pyserial
    rich
  ];

  disabledTests = [
    # Exclude system tests that require hardware
    "sys_tests"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "numato_gpio"
  ];

  meta = {
    description = "Python API for Numato GPIO Expanders";
    homepage = "https://github.com/clssn/numato-gpio";
    changelog = "https://github.com/clssn/numato-gpio/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
