{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  matplotlib,
  numpy,
  pytest-cov-stub,
  pytestCheckHook,
  scipy,
}:

buildPythonPackage rec {
  pname = "kneed";
  version = "0.8.6";

  src = fetchFromGitHub {
    owner = "arvkevi";
    repo = "kneed";
    tag = "v${version}";
    sha256 = "sha256-A9d5igX9Eqr3rgx93VMee9yFEs6WfO0bb/eCEFCxUJg=";
  };

  checkInputs = [
    pytestCheckHook
    pytest-cov-stub
    matplotlib
  ];

  build-system = [ hatchling ];

  dependencies = [
    numpy
    scipy
  ];

  disabledTestPaths = [
    # Fails when matplotlib is installed
    "tests/test_no_matplotlib.py"
  ];

  pyproject = true;

  meta = {
    description = "Knee point detection in Python";
    homepage = "https://github.com/arvkevi/kneed";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ tm-drtina ];
  };
}
