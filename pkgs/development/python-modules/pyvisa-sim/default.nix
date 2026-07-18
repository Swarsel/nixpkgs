{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  pyvisa,
  pyyaml,
  setuptools,
  setuptools-scm,
  stringparser,
  typing-extensions,
  wheel,
}:

buildPythonPackage rec {
  pname = "pyvisa-sim";
  version = "0.7.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-EbEGWOIVJwjuraDIZifYlMTRFIQxLwLTzzhRlrS8hw8=";
    pname = "pyvisa_sim";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    pyvisa
    pyyaml
    stringparser
    typing-extensions
  ];

  # should be fixed after 0.5.1, remove at next release
  disabledTestPaths = [ "pyvisa_sim/testsuite/test_all.py" ];
  pyproject = true;
  pythonImportsCheck = [ "pyvisa_sim" ];

  meta = {
    description = "Simulated backend for PyVISA implementing TCPIP, GPIB, RS232, and USB resources";
    homepage = "https://pyvisa.readthedocs.io/projects/pyvisa-sim/en/latest/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ evilmav ];
  };
}
