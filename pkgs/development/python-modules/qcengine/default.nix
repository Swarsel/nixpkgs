{
  lib,
  buildPythonPackage,
  fetchPypi,
  packaging,
  psutil,
  py-cpuinfo,
  pydantic,
  pydantic-settings,
  pytestCheckHook,
  pyyaml,
  qcelemental,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "qcengine";
  version = "0.50.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-x218Sq4QOoqTpcSM9TzQydhIn9LthflCuNh/P0stZmU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    pyyaml
    py-cpuinfo
    psutil
    qcelemental
    pydantic
    pydantic-settings
    packaging
  ];

  # These tests require network access
  disabledTestPaths = [
    "qcengine/tests/test_harness_canonical.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "qcengine" ];

  meta = {
    description = "Quantum chemistry program executor and IO standardizer (QCSchema) for quantum chemistry";
    homepage = "https://molssi.github.io/QCElemental/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sheepforce ];
    mainProgram = "qcengine";
  };
}
