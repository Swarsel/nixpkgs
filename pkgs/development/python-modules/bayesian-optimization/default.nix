{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  # tests
  jupyter,
  matplotlib,
  nbconvert,
  nbformat,
  numpy,
  packaging,
  pytestCheckHook,
  # dependencies
  scikit-learn,
  scipy,
  # build-system
  uv-build,
}:

buildPythonPackage rec {
  pname = "bayesian-optimization";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "bayesian-optimization";
    repo = "BayesianOptimization";
    tag = "v${version}";
    hash = "sha256-tehmtySHiwXQBFZDcj87DAP0WMyp3kDXW0LZApkHZwY=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.7.21,<0.8.0" "uv_build"
  '';

  nativeCheckInputs = [
    jupyter
    matplotlib
    nbconvert
    nbformat
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ uv-build ];

  dependencies = [
    scikit-learn
    numpy
    scipy
    colorama
    packaging
  ];

  pyproject = true;
  pythonImportsCheck = [ "bayes_opt" ];

  meta = {
    description = "Python implementation of global optimization with gaussian processes";
    homepage = "https://github.com/bayesian-optimization/BayesianOptimization";
    changelog = "https://github.com/bayesian-optimization/BayesianOptimization/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.juliendehos ];
  };
}
