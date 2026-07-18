{
  lib,
  buildPythonPackage,
  fetchPypi,
  h5py,
  ipython,
  numba,
  numpy,
  pytestCheckHook,
  scipy,
  setuptools,
  sparse,
}:

buildPythonPackage rec {
  pname = "clifford";
  version = "1.5.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-NISzEs/w4tXhT7mUCbgkIZPDWN+qave8bqIwxGBuZvM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    ipython
  ];

  # avoid collecting local files
  preCheck = ''
    cd clifford/test
  '';

  build-system = [ setuptools ];

  dependencies = [
    h5py
    numba
    numpy
    scipy
    sparse
  ];

  disabledTestPaths = [
    # Disable failing tests
    "test_g3c_tools.py"
    "test_multivector_inverse.py"
  ];

  disabledTests = [
    "veryslow"
    "test_algebra_initialisation"
    "test_cga"
    "test_grade_projection"
    "test_multiple_grade_projection"
    "test_inverse"
    "test_inv_g4"
  ];

  pyproject = true;
  pythonImportsCheck = [ "clifford" ];

  meta = {
    description = "Numerical Geometric Algebra Module";
    homepage = "https://clifford.readthedocs.io";
    changelog = "https://github.com/pygae/clifford/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    # Broken with numba >= 0.54
    # see https://github.com/pygae/clifford/issues/430
    broken = lib.versionAtLeast numba.version "0.58";
  };
}
