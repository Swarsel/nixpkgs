{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cvxpy,
  matplotlib,
  numpy,
  pandas,
  pytestCheckHook,
  scipy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pepit";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "PerformanceEstimation";
    repo = "PEPit";
    tag = version;
    hash = "sha256-PCWYfJ1h4P0X4KLNdIivLrPVAR7205K1Ii5ROuGHULo=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "{{VERSION_PLACEHOLDER}}" "${version}"
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    cvxpy
    numpy
    pandas
    scipy
    matplotlib
  ];

  pyproject = true;

  pythonImportsCheck = [
    "PEPit"
  ];

  meta = {
    description = "Performance Estimation in Python";
    homepage = "https://pepit.readthedocs.io/";
    changelog = "https://pepit.readthedocs.io/en/latest/whatsnew/${version}.html";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wegank ];
  };
}
