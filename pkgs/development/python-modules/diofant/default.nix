{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  gmpy2,
  hypothesis,
  mpmath,
  numpy,
  pexpect,
  pytest-cov-stub,
  pytest-xdist,
  pytestCheckHook,
  scipy,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "diofant";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "diofant";
    repo = "diofant";
    tag = "v${version}";
    hash = "sha256-uQvAYSURDhuAKcX0WVMk4y2ZXiiq0lPZct/7A5n5t34=";
  };

  doCheck = false; # some tests get stuck easily

  nativeCheckInputs = [
    hypothesis
    pexpect
    pytest-cov-stub
    pytest-xdist
    pytestCheckHook
  ];

  build-system = [ setuptools-scm ];
  dependencies = [ mpmath ];

  disabledTestMarks = [
    "slow"
  ];

  disabledTests = [
    # AssertionError: assert '9.9012134805...5147838841057' == '2.7182818284...2178525166427'
    "test_evalf_fast_series"
    # AssertionError: assert Float('0.0051000000000000004', dps=15) == Float('0.010050166663333571', dps=15)
    "test_evalf_sum"
  ];

  optional-dependencies = {
    exports = [
      cython
      numpy
      scipy
    ];

    gmpy = [ gmpy2 ];
  };

  pyproject = true;

  pytestFlags = [
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [ "diofant" ];

  meta = {
    description = "Python CAS library";
    homepage = "https://github.com/diofant/diofant";
    changelog = "https://diofant.readthedocs.io/en/latest/release/notes-${src.tag}.html";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
