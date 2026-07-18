{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  gmpy2,
  hypothesis,
  isPyPy,
  pexpect,
  pytest-xdist,
  pytestCheckHook,
  # Reverse dependency
  sage,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "mpmath";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "mpmath";
    repo = "mpmath";
    tag = finalAttrs.version;
    hash = "sha256-ykfKrpDri+4n9Y26S7nFl6nF0CV6V0A11ijmt8/apvg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-xdist
    hypothesis
    pexpect
  ];

  # Ugly hack to preserve the hash on non-`x86_64-darwin` platforms
  ${if stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64 then "disabledTests" else null} =
    [
      # Expected:
      #     -0.5440211108893698
      # Got:
      #     -0.5440211108893699
      "contexts.rst"
    ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  optional-dependencies = {
    gmpy = lib.optionals (!isPyPy) [ gmpy2 ];
  };

  pyproject = true;

  passthru.tests = {
    inherit sage;
  };

  meta = {
    description = "Pure-Python library for multiprecision floating arithmetic";
    homepage = "https://mpmath.org/";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
