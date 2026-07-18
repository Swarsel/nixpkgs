{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  gmp,
  hypothesis,
  isPyPy,
  libmpc,
  mpfr,
  mpmath,
  pytestCheckHook,
  # Reverse dependency
  sage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "gmpy2";
  version = "2.2.2";

  src = fetchFromGitHub {
    owner = "aleaxit";
    repo = "gmpy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-joeHec/d82sovfASCU3nlNL6SaThnS/XYPqujiZ9h8s=";
  };

  buildInputs = [
    gmp
    mpfr
    libmpc
  ];

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
    cython
    mpmath
  ];

  # make relative imports in tests work properly
  preCheck = ''
    rm gmpy2 -r
  '';

  build-system = [ setuptools ];
  disabled = isPyPy;
  pyproject = true;
  pythonImportsCheck = [ "gmpy2" ];

  passthru.tests = {
    inherit sage;
  };

  meta = {
    description = "Interface to GMP, MPFR, and MPC for Python 3.7+";
    homepage = "https://github.com/aleaxit/gmpy/";
    changelog = "https://github.com/aleaxit/gmpy/blob/${finalAttrs.src.rev}/docs/history.rst";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ tomasajt ];
  };
})
