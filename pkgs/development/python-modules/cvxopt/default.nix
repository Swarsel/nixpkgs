{
  lib,
  blas,
  buildPythonPackage,
  fetchPypi,
  isPyPy,
  lapack,
  setuptools-scm,
  suitesparse,
  unittestCheckHook,
  fftw ? null,
  glpk ? null,
  gsl ? null,
  withFftw ? true,
  withGlpk ? true,
  withGsl ? true,
}:

assert (!blas.isILP64) && (!lapack.isILP64);

buildPythonPackage rec {
  pname = "cvxopt";
  version = "1.3.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-gFnO9B8fEVyHvJt1/sn4bblefwr88DpS1hm6Qz5EO8s=";
  };

  buildInputs = [
    blas
    lapack
  ];

  # similar to Gsl, glpk, fftw there is also a dsdp interface
  # but dsdp is not yet packaged in nixpkgs
  env = {
    CVXOPT_BLAS_LIB = "blas";
    CVXOPT_BUILD_DSDP = "0";
    CVXOPT_LAPACK_LIB = "lapack";
    CVXOPT_SUITESPARSE_INC_DIR = "${lib.getDev suitesparse}/include";
    CVXOPT_SUITESPARSE_LIB_DIR = "${lib.getLib suitesparse}/lib";
  }
  // lib.optionalAttrs withGsl {
    CVXOPT_BUILD_GSL = "1";
    CVXOPT_GSL_INC_DIR = "${lib.getDev gsl}/include";
    CVXOPT_GSL_LIB_DIR = "${lib.getLib gsl}/lib";
  }
  // lib.optionalAttrs withGlpk {
    CVXOPT_BUILD_GLPK = "1";
    CVXOPT_GLPK_INC_DIR = "${lib.getDev glpk}/include";
    CVXOPT_GLPK_LIB_DIR = "${lib.getLib glpk}/lib";
  }
  // lib.optionalAttrs withFftw {
    CVXOPT_BUILD_FFTW = "1";
    CVXOPT_FFTW_INC_DIR = "${lib.getDev fftw}/include";
    CVXOPT_FFTW_LIB_DIR = "${lib.getLib fftw}/lib";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools-scm ];
  disabled = isPyPy; # hangs at [translation:info]
  format = "setuptools";

  unittestFlagsArray = [
    "-s"
    "tests"
  ];

  meta = {
    description = "Python Software for Convex Optimization";

    longDescription = ''
      CVXOPT is a free software package for convex optimization based on the
      Python programming language. It can be used with the interactive
      Python interpreter, on the command line by executing Python scripts,
      or integrated in other software via Python extension modules. Its main
      purpose is to make the development of software for convex optimization
      applications straightforward by building on Python's extensive
      standard library and on the strengths of Python as a high-level
      programming language.
    '';

    homepage = "https://cvxopt.org/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ edwtjo ];
  };
}
