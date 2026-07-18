{
  lib,
  stdenv,
  fetchFromGitHub,
  # tests
  autograd,
  buildPythonPackage,
  jax,
  matplotlib,
  # dependencies
  numpy,
  pytestCheckHook,
  scipy,
  # build-system
  setuptools-scm,
  tensorflow,
  torch,
}:

buildPythonPackage (finalAttrs: {
  pname = "pymanopt";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "pymanopt";
    repo = "pymanopt";
    tag = finalAttrs.version;
    hash = "sha256-LOEulticgCWZBCf3qj5KFBHt0lMd4H85368IhG3DQ4g=";
  };

  preConfigure = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"pip==22.3.1",' ""
  '';

  nativeCheckInputs = [
    autograd
    jax
    matplotlib
    pytestCheckHook
    tensorflow
    torch
  ];

  build-system = [
    setuptools-scm
  ];

  dependencies = [
    numpy
    scipy
  ];

  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [
    # FloatingPointError: divide by zero encountered in det
    "tests/manifolds/test_positive_definite.py::TestMultiSpecialHermitianPositiveDefiniteManifold::test_retraction"
    "tests/manifolds/test_positive_definite.py::TestSingleSpecialHermitianPositiveDefiniteManifold::test_retraction"
  ];

  disabledTests = [
    # ValueError: setting an array element with a sequence
    "test_check_gradient"
    "test_check_hessian"
    "test_check_retraction"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pymanopt" ];

  meta = {
    description = "Python toolbox for optimization on Riemannian manifolds with support for automatic differentiation";
    homepage = "https://www.pymanopt.org/";
    changelog = "https://github.com/pymanopt/pymanopt/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ yl3dy ];
  };
})
