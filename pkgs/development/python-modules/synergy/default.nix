{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  matplotlib,
  numpy,
  pandas,
  plotly,
  pytestCheckHook,
  scipy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "synergy";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "djwooten";
    repo = "synergy";
    tag = "v${version}";
    hash = "sha256-df5CBEcRx55/rSMc6ygMVrHbbEcnU1ISJheO+WoBSCI=";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    numpy
    scipy
    matplotlib
    plotly
    pandas
  ];

  disabledTests = [
    # flaky: hypothesis.errors.FailedHealthCheck
    "test_asymptotic_limits"
    "test_inverse"
    # AssertionError: synthetic_BRAID_reference_1.csv
    #  E3=0 not in (0.10639582639915163, 1.6900177333904622)
    "test_BRAID_fit_bootstrap"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # AssertionError: np.False_ is not true
    "test_fit_loewe_antagonism"
  ];

  pyproject = true;
  pythonImportsCheck = [ "synergy" ];

  meta = {
    description = "Python library for calculating, analyzing, and visualizing drug combination synergy";
    homepage = "https://github.com/djwooten/synergy";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
  };
}
