{
  lib,
  stdenv,
  buildPythonPackage,
  llvmPackages,
  ml-dtypes,
  numpy,
  pkgs,
  pytest-repeat,
  pytest-xdist,
  pytestCheckHook,
  scipy,
  setuptools,
}:

buildPythonPackage {
  inherit (pkgs.numkong) pname version src;
  buildInputs = lib.optional stdenv.hostPlatform.isDarwin llvmPackages.openmp;

  nativeCheckInputs = [
    numpy
    scipy
    ml-dtypes
    pytest-repeat
    pytest-xdist
    pytestCheckHook
    # there are more tests for big libraries, but we avoid them to not explode the closure size
  ];

  build-system = [
    setuptools
  ];

  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [
    # slight floating point error
    "test/test_similarities.py::test_cdist_float_accuracy"
    "test/test_similarities.py::test_cdist_jaccard"
  ];

  pyproject = true;
  pythonImportsCheck = [ "numkong" ];

  meta = {
    inherit (pkgs.numkong.meta)
      description
      homepage
      changelog
      license
      maintainers
      ;
  };
}
