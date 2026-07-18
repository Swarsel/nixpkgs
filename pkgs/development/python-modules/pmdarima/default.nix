{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  joblib,
  matplotlib,
  meson-python,
  numpy,
  pandas,
  pytestCheckHook,
  python,
  scikit-learn,
  scipy,
  statsmodels,
  urllib3,
}:

buildPythonPackage rec {
  pname = "pmdarima";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "alkaline-ml";
    repo = "pmdarima";
    tag = "v${version}";
    hash = "sha256-NSBmii+2AQidZo8sPARxtLELk5Ec6cHaZddswifFqwQ=";
  };

  postPatch = ''
    patchShebangs build_tools/get_tag.py
  '';

  env = {
    GITHUB_REF = "refs/tags/v${version}";
  };

  nativeCheckInputs = [
    matplotlib
    pytestCheckHook
  ];

  # Make sure we're running the tests for the actually installed
  # package, so that cython's compiled files are available.
  preCheck = ''
    cd $out/${python.sitePackages}
  '';

  build-system = [
    cython
    meson-python
  ];

  dependencies = [
    joblib
    numpy
    pandas
    scikit-learn
    scipy
    statsmodels
    urllib3
  ];

  disabledTests = [
    # touches internet
    "test_load_from_web"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pmdarima" ];

  pythonRemoveDeps = [
    # https://github.com/alkaline-ml/pmdarima/pull/616
    "setuptools"
  ];

  meta = {
    description = "Statistical library designed to fill the void in Python's time series analysis capabilities, including the equivalent of R's auto.arima function";
    homepage = "https://github.com/alkaline-ml/pmdarima";
    changelog = "https://github.com/alkaline-ml/pmdarima/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
