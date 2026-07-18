{
  lib,
  fetchFromGitHub,
  autograd,
  autograd-gamma,
  buildPythonPackage,
  dill,
  flaky,
  formulaic,
  jinja2,
  matplotlib,
  numpy,
  pandas,
  psutil,
  pytestCheckHook,
  scikit-learn,
  scipy,
  setuptools,
  sybil,
}:

buildPythonPackage rec {
  pname = "lifelines";
  version = "0.30.3";

  src = fetchFromGitHub {
    owner = "CamDavidsonPilon";
    repo = "lifelines";
    tag = "v${version}";
    hash = "sha256-A9MsQN/JGCQ4cYNIZI5LBKpRb44uI/SM8eT4/nKpsXQ=";
  };

  nativeCheckInputs = [
    dill
    flaky
    jinja2
    psutil
    pytestCheckHook
    scikit-learn
    sybil
  ];

  build-system = [ setuptools ];

  dependencies = [
    autograd
    autograd-gamma
    formulaic
    matplotlib
    numpy
    pandas
    scipy
  ];

  disabledTestPaths = [ "lifelines/tests/test_estimation.py" ];

  disabledTests = [
    "test_datetimes_to_durations_with_different_frequencies"
    # AssertionError
    "test_mice_scipy"
  ];

  pyproject = true;
  pythonImportsCheck = [ "lifelines" ];

  meta = {
    description = "Survival analysis in Python";
    homepage = "https://lifelines.readthedocs.io";
    changelog = "https://github.com/CamDavidsonPilon/lifelines/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ swflint ];
  };
}
