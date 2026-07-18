{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cexprtk,
  configparser,
  deepdiff,
  future,
  openpyxl,
  pyparsing,
  pytestCheckHook,
  pythonAtLeast,
  scipy,
  setuptools,
  sympy,
  wrapt,
}:

buildPythonPackage rec {
  pname = "atsim-potentials";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "mjdrushton";
    repo = "atsim-potentials";
    tag = version;
    hash = "sha256-G7lNqwEUwAT0f7M2nUTCxpXOAl6FWKlh7tcsvbur1eM=";
  };

  nativeCheckInputs = [
    deepdiff
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    cexprtk
    configparser
    future
    openpyxl
    pyparsing
    scipy
    sympy
    wrapt
  ];

  # these files try to import `distutils` removed in Python 3.12
  disabledTestPaths = lib.optionals (pythonAtLeast "3.12") [
    "tests/config/test_configuration_eam.py"
    "tests/config/test_configuration_eam_fs.py"
    "tests/config/test_configuration_pair.py"
    "tests/test_dlpoly_writeTABEAM.py"
    "tests/test_documentation_examples.py"
    "tests/test_eam_adp_writer.py"
    "tests/test_gulp_writer.py"
    "tests/test_lammpsWriteEAM.py"
  ];

  disabledTests = [
    # Missing lammps executable
    "eam_tabulate_example2TestCase"
  ];

  pyproject = true;
  pythonImportsCheck = [ "atsim.potentials" ];

  meta = {
    description = "Provides tools for working with pair and embedded atom method potential models including tabulation routines for DL_POLY and LAMMPS";
    homepage = "https://github.com/mjdrushton/atsim-potentials";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "potable";
  };
}
