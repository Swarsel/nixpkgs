{
  lib,
  buildPythonPackage,
  fetchPypi,
  numba,
  pytestCheckHook,
  scipy,
}:

buildPythonPackage rec {
  pname = "numba-scipy";
  version = "0.4.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-RDZF1mNcZnrcOzjQpjbZq8yXHnjeLAeAjYmvzXvFhEQ=";
  };

  propagatedBuildInputs = [
    scipy
    numba
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  format = "setuptools";
  pythonImportsCheck = [ "numba_scipy" ];

  pythonRelaxDeps = [
    "scipy"
    "numba"
  ];

  meta = {
    description = "Extends Numba to make it aware of SciPy";
    homepage = "https://github.com/numba/numba-scipy";
    changelog = "https://github.com/numba/numba-scipy/blob/master/CHANGE_LOG";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ Etjean ];
  };
}
