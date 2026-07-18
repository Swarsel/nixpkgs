{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  mpmath,
  numpy,
  pytest-xdist,
  # tests
  pytestCheckHook,
  scipy,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "hankel";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "steven-murray";
    repo = "hankel";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/5PvbH8zz2siLS1YJYRSrl/Cpi0WToBu1TJhlek8VEE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-xdist
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    mpmath
    numpy
    scipy
  ];

  disabledTests = [
    # ValueError: Calling nonzero on 0d arrays is not allowed.
    "test_nu0"
  ];

  pyproject = true;
  pythonImportsCheck = [ "hankel" ];

  meta = {
    description = "Implementation of Ogata's (2005) method for Hankel transforms";
    homepage = "https://github.com/steven-murray/hankel";
    changelog = "https://github.com/steven-murray/hankel/v${finalAttrs.version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
