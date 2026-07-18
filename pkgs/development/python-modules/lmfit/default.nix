{
  lib,
  # dependencies
  asteval,
  buildPythonPackage,
  dill,
  fetchPypi,
  matplotlib,
  numpy,
  pandas,
  pytest-cov-stub,
  # tests
  pytestCheckHook,
  scipy,
  # build-system
  setuptools,
  setuptools-scm,
  uncertainties,
}:

buildPythonPackage rec {
  pname = "lmfit";
  version = "1.3.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-PCLCjEP3F/bFtKO9geiTohSXOcJqWSwEby4zwjz75Jc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    matplotlib
    pandas
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    asteval
    dill
    numpy
    scipy
    uncertainties
  ];

  disabledTests = [ "test_check_ast_errors" ];
  pyproject = true;
  pythonImportsCheck = [ "lmfit" ];

  meta = {
    description = "Least-Squares Minimization with Bounds and Constraints";
    homepage = "https://lmfit.github.io/lmfit-py/";
    changelog = "https://github.com/lmfit/lmfit-py/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
