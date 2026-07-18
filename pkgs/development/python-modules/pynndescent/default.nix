{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  joblib,
  llvmlite,
  numba,
  # tests
  pytestCheckHook,
  scikit-learn,
  scipy,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pynndescent";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "lmcinnes";
    repo = "pynndescent";
    tag = "release-${finalAttrs.version}";
    hash = "sha256-RfIbPPyx+Y7niuFrLjA02cUDHTSv9s5E4JiXv4ZBNEc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    joblib
    llvmlite
    numba
    scikit-learn
    scipy
  ];

  disabledTests = [
    # AssertionError: Arrays are not almost equal to 6 decimals
    "test_seuclidean"

    # sklearn.utils._param_validation.InvalidParameterError: The 'metric' parameter of
    # pairwise_distances must be a str among ...
    "test_binary_check"
    "test_sparse_binary_check"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pynndescent" ];

  meta = {
    description = "Nearest Neighbor Descent";
    homepage = "https://github.com/lmcinnes/pynndescent";
    changelog = "https://github.com/lmcinnes/pynndescent/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ mic92 ];

    badPlatforms = [
      # The majority of tests are crashing:
      # Fatal Python error: Segmentation fault
      "aarch64-linux"
    ];
  };
})
