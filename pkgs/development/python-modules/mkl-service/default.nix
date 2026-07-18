{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  mkl,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mkl-service";
  version = "2.6.1";

  src = fetchFromGitHub {
    owner = "IntelPython";
    repo = "mkl-service";
    tag = version;
    hash = "sha256-qiypoeCWUIghLmEYVOJaT4XUT7TNAJjWxnIq7HOZlkY=";
  };

  env.MKLROOT = mkl;
  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    cd $out
  '';

  build-system = [
    cython
    setuptools
  ];

  dependencies = [ mkl ];

  disabledTests = [
    # require SIMD compilation
    "test_cbwr_all"
    "test_cbwr_branch"
  ];

  pyproject = true;
  pythonImportsCheck = [ "mkl" ];

  meta = {
    description = "Python hooks for Intel(R) Math Kernel Library runtime control settings";
    homepage = "https://github.com/IntelPython/mkl-service";
    license = lib.licenses.bsd3;
  };
}
