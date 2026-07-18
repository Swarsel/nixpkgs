{
  lib,
  fetchFromGitHub,
  # dependencies
  autograd,
  buildPythonPackage,
  future,
  # tests
  matplotlib,
  numba,
  numpy,
  pandas,
  patsy,
  pytest-xdist,
  pytestCheckHook,
  scikit-learn,
  scipy,
  seaborn,
  # build-system
  setuptools,
  statsmodels,
}:

buildPythonPackage rec {
  pname = "hyppo";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "neurodata";
    repo = "hyppo";
    tag = "v${version}";
    hash = "sha256-7Y+UhneIGwqjsPCnGAQWF/l4r1gFbYs3fdHhV46ZBjA=";
  };

  # some of the doctests (4/21) are broken, e.g. unbound variables, nondeterministic with insufficient tolerance, etc.
  # (note upstream's .circleci/config.yml only tests test_*.py files despite their pytest.ini adding --doctest-modules)
  postPatch = ''
    substituteInPlace pytest.ini --replace-fail "addopts = --doctest-modules" ""
  '';

  nativeCheckInputs = [
    pytest-xdist
    pytestCheckHook
    matplotlib
    seaborn
  ];

  build-system = [ setuptools ];

  dependencies = [
    autograd
    future
    numba
    numpy
    pandas
    patsy
    scikit-learn
    scipy
    statsmodels
  ];

  enabledTestPaths = [
    "hyppo"
  ];

  pyproject = true;

  meta = {
    description = "Python package for multivariate hypothesis testing";
    homepage = "https://github.com/neurodata/hyppo";
    changelog = "https://github.com/neurodata/hyppo/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
