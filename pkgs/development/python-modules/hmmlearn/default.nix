{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  numpy,
  pybind11,
  pytestCheckHook,
  scikit-learn,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "hmmlearn";
  version = "0.3.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-HTxdxMUlfgwjjcH+U4dwC4y5h+q4CO2z4Mc4KfHMROw=";
  };

  buildInputs = [
    setuptools-scm
    cython
    pybind11
  ];

  propagatedBuildInputs = [
    numpy
    scikit-learn
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";

  pytestFlags = [
    "--pyargs"
    "hmmlearn"
  ];

  pythonImportsCheck = [ "hmmlearn" ];

  meta = {
    description = "Hidden Markov Models in Python with scikit-learn like API";
    homepage = "https://github.com/hmmlearn/hmmlearn";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
