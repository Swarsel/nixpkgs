{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "primepy";
  version = "1.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Jf1+JTRLB4mlmEx12J8FT88fGAvvIMmY5L77rJLeRmk=";
    pname = "primePy";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  pyproject = true;
  pythonImportsCheck = [ "primePy" ];

  meta = {
    description = "This module contains several useful functions to work with prime numbers. from primePy import primes";
    homepage = "https://pypi.org/project/primePy/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthewcroughan ];
  };
}
