{
  lib,
  stdenv,
  fetchFromGitHub,
  # needed to run
  astropy,
  buildPythonPackage,
  # needed to build
  cython,
  extension-helpers,
  numpy,
  oldest-supported-numpy,
  pyparsing,
  pytest-astropy,
  # needed to check
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyregion";
  version = "2.3.0";

  # pypi src contains cython-produced .c files which don't compile
  # with python3.9
  src = fetchFromGitHub {
    owner = "astropy";
    repo = "pyregion";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mEO2PbUSTVy7Qmm723/lGL6PYQzbRazIPZH51SWebvs=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-astropy
  ];

  # Tests must be run in the build directory
  preCheck = ''
    pushd build/lib.*
  '';

  postCheck = ''
    popd
  '';

  build-system = [
    cython
    extension-helpers
    oldest-supported-numpy
    setuptools
    setuptools-scm
  ];

  dependencies = [
    astropy
    numpy
    pyparsing
  ];

  pyproject = true;

  meta = {
    description = "Python parser for ds9 region files";
    homepage = "https://github.com/astropy/pyregion";
    changelog = "https://github.com/astropy/pyregion/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.smaret ];
  };
})
