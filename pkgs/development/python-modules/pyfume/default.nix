{
  lib,
  buildPythonPackage,
  fetchPypi,
  fst-pso,
  numpy,
  pandas,
  scipy,
  setuptools,
  simpful,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pyfume";
  version = "0.3.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-UwW5OwFfu01lDKwz72iB2egbOoxb+t8UnEFIUjZmffU=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    fst-pso
    numpy
    pandas
    scipy
    simpful
    typing-extensions
  ];

  # Module has not test
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "pyfume" ];

  pythonRelaxDeps = [
    "fst-pso"
    "numpy"
    "pandas"
    "scipy"
  ];

  meta = {
    description = "Python package for fuzzy model estimation";
    homepage = "https://github.com/CaroFuchs/pyFUME";
    changelog = "https://github.com/CaroFuchs/pyFUME/releases/tag/${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
