{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  scikit-base,
  scipy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pykalman";
  version = "0.11.2";

  src = fetchFromGitHub {
    owner = "pykalman";
    repo = "pykalman";
    tag = "v${version}";
    hash = "sha256-F5p0li1ZKDd9gDwkL318hlL3QzD2MA3SyEtIB68UOFg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    numpy
    scipy
    scikit-base
  ];

  pyproject = true;
  pythonImportsCheck = [ "pykalman" ];
  pythonRelaxDeps = [ "scikit-base" ];

  meta = {
    description = "Implementation of the Kalman Filter, Kalman Smoother, and EM algorithm in Python";
    homepage = "https://github.com/pykalman/pykalman";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
