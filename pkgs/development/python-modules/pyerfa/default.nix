{
  lib,
  buildPythonPackage,
  fetchPypi,
  jinja2,
  liberfa,
  numpy,
  packaging,
  pytest-doctestplus,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pyerfa";
  version = "2.0.1.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-F9ayT+SEbGXV59jDYtywgZncY7MKI2rt1zh1zIPh9sA=";
  };

  buildInputs = [ liberfa ];
  # See https://github.com/liberfa/pyerfa/issues/112#issuecomment-1721197483
  env.NIX_CFLAGS_COMPILE = "-O2";

  preBuild = ''
    export PYERFA_USE_SYSTEM_LIBERFA=1
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-doctestplus
  ];

  # Getting circular import errors without this, not clear yet why. This was mentioned to
  # upstream at: https://github.com/liberfa/pyerfa/issues/112 and downstream at
  # https://github.com/NixOS/nixpkgs/issues/255262
  preCheck = ''
    cd $out
  '';

  build-system = [
    jinja2
    numpy
    packaging
    setuptools
    setuptools-scm
  ];

  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "erfa" ];

  meta = {
    description = "Python bindings for ERFA routines";

    longDescription = ''
      PyERFA is the Python wrapper for the ERFA library (Essential Routines
      for Fundamental Astronomy), a C library containing key algorithms for
      astronomy, which is based on the SOFA library published by the
      International Astronomical Union (IAU). All C routines are wrapped as
      Numpy universal functions, so that they can be called with scalar or
      array inputs.
    '';

    homepage = "https://github.com/liberfa/pyerfa";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.rmcgibbo ];
  };
}
