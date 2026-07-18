{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  future,
  matplotlib,
  numpy,
  # tests
  pytestCheckHook,
  scikit-learn,
  scipy,
  # build-system
  setuptools,
  torch,
}:

buildPythonPackage rec {
  pname = "ezyrb";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "mathLab";
    repo = "EZyRB";
    tag = "v${version}";
    hash = "sha256-dta8Vc7sUQEtcFEJaFbJUafSsjgZ7ZSLaFJTOMSfKmU=";
  };

  # AttributeError: module 'numpy' has no attribute 'VisibleDeprecationWarning'
  postPatch = ''
    substituteInPlace \
      tests/test_k_neighbors_regressor.py \
      tests/test_linear.py \
      tests/test_radius_neighbors_regressor.py \
      --replace-fail \
        "np.VisibleDeprecationWarning" \
        "np.exceptions.VisibleDeprecationWarning"
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    future
    matplotlib
    numpy
    scikit-learn
    scipy
    torch
  ];

  disabledTestPaths = [
    # Exclude long tests
    "tests/test_podae.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "ezyrb" ];

  meta = {
    description = "Easy Reduced Basis method";
    homepage = "https://mathlab.github.io/EZyRB/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ yl3dy ];
    downloadPage = "https://github.com/mathLab/EZyRB/releases";
  };
}
