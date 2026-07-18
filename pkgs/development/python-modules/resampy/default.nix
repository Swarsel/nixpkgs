{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  numba,
  numpy,
  optuna,
  pytest-cov-stub,
  pytestCheckHook,
  scipy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "resampy";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "bmcfee";
    repo = "resampy";
    tag = version;
    hash = "sha256-LOWpOPAEK+ga7c3bR15QvnHmON6ARS1Qee/7U/VMlTY=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
    scipy
  ];

  build-system = [ setuptools ];

  dependencies = [
    numpy
    numba
  ];

  disabledTests = lib.optionals (stdenv.hostPlatform.system == "aarch64-linux") [
    # crashing the interpreter
    "test_quality_sine_parallel"
    "test_resample_nu_quality_sine_parallel"
  ];

  optional-dependencies.design = [ optuna ];
  pyproject = true;
  pythonImportsCheck = [ "resampy" ];

  meta = {
    description = "Efficient signal resampling";
    homepage = "https://github.com/bmcfee/resampy";
    license = lib.licenses.isc;
    maintainers = [ ];
  };
}
