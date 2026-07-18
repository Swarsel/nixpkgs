{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  python-dateutil,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pycollada";
  version = "0.9.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-w01tzw/i66WJb3HJbTehwP4aYfCEQPoM/Ow9woldMwI=";
  };

  # Some tests fail because they refer to test data files that don't exist
  # (upstream packaging issue)
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    python-dateutil
  ];

  pyproject = true;

  pythonImportsCheck = [
    "collada"
  ];

  meta = {
    description = "Python library for reading and writing collada documents";
    homepage = "http://pycollada.github.io/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ bjornfor ];
    platforms = with lib.platforms; linux ++ darwin;
  };
}
