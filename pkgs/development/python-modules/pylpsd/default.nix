{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  scipy,
}:

buildPythonPackage rec {
  pname = "pylpsd";
  version = "0.1.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-evPL9vF75S8ATkFwzQjh4pLI/aXGXWwoypCb24nXAN8=";
  };

  propagatedBuildInputs = [
    numpy
    scipy
  ];

  # Tests fail and there are none
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "pylpsd" ];

  meta = {
    description = "Python implementation of the LPSD algorithm for computing power spectral density with logarithmically spaced points";
    homepage = "https://github.com/bleykauf/py-lpsd";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
