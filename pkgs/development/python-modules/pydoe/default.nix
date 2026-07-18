{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  scipy,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "pydoe";
  version = "0.3.8";

  src = fetchPypi {
    inherit version;
    hash = "sha256-y9bxSuJtPJ9zYBMgX1PqEZGt1FZwM8Pud7fdNWVmxLY=";
    extension = "zip";
    pname = "pyDOE";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    scipy
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyDOE" ];

  meta = {
    description = "Design of experiments for Python";
    homepage = "https://github.com/tisimst/pyDOE";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
