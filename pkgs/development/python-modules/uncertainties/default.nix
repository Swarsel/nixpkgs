{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # optional-dependencies
  numpy,
  # tests
  pytestCheckHook,
  scipy,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "uncertainties";
  version = "3.2.4";

  src = fetchFromGitHub {
    owner = "lmfit";
    repo = "uncertainties";
    tag = version;
    hash = "sha256-XfEiE27azEBNCZ6sIBncJI1cYocoXwgxEkclVgR5O34=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    scipy
  ]
  ++ optional-dependencies.arrays;

  build-system = [
    setuptools
    setuptools-scm
  ];

  disabledTests = [
    # Flaky tests, see: https://github.com/lmfit/uncertainties/issues/343
    "test_repeated_summation_complexity"
  ];

  optional-dependencies.arrays = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "uncertainties" ];

  meta = {
    description = "Transparent calculations with uncertainties on the quantities involved (aka error propagation)";
    homepage = "https://uncertainties.readthedocs.io/";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      rnhmjoj
      doronbehar
    ];
  };
}
