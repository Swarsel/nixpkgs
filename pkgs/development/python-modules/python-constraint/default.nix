{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  pep440,
  poetry-core,
  pytest-cov-stub,
  # Check inputs
  pytestCheckHook,
  setuptools,
  tomli,
}:

buildPythonPackage rec {
  pname = "python-constraint";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "python-constraint";
    repo = "python-constraint";
    tag = version;
    sha256 = "sha256-VTecK82VSDoUOkPnuC+PnQYPjPBsaPeWCqm2st6Wwvg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    tomli
    pep440
  ];

  build-system = [
    setuptools
    poetry-core
    cython
  ];

  disabledTestPaths = [
    "tests/test_util_benchmark.py"
  ];

  pyproject = true;

  meta = {
    description = "Constraint Solving Problem resolver for Python";
    homepage = "https://labix.org/doc/constraint/";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    downloadPage = "https://github.com/python-constraint/python-constraint/releases";
  };
}
