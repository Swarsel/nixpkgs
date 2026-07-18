{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  packaging,
  pillow,
  pytestCheckHook,
  quantities,
  setuptools,
  which,
}:

buildPythonPackage rec {
  pname = "neo";
  version = "0.14.4";

  src = fetchFromGitHub {
    owner = "NeuralEnsemble";
    repo = "python-neo";
    tag = version;
    hash = "sha256-VdT7PFSle8HxWfsPrrI+mHtsTO315+Sw0RGx8HSYtwk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pillow
    which
  ];

  build-system = [ setuptools ];

  dependencies = [
    numpy
    packaging
    quantities
  ];

  disabledTestPaths = [
    # Requires network and export HOME dir
    "neo/test/rawiotest/test_maxwellrawio.py"
  ];

  disabledTests = [
    # numpy 2.x boolean index strictness regression
    "test__time_slice_deepcopy_data"
  ];

  pyproject = true;
  pythonImportsCheck = [ "neo" ];

  meta = {
    description = "Package for representing electrophysiology data";
    homepage = "https://neuralensemble.org/neo/";
    changelog = "https://neo.readthedocs.io/en/${src.tag}/releases/${src.tag}.html";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
