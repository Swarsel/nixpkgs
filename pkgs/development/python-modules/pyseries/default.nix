{
  lib,
  buildPythonPackage,
  # dependencies
  deepdish,
  fetchPypi,
  matplotlib,
  numpy,
  obspy,
  pandas,
  pyedflib,
  scikit-learn,
  scipy,
  seaborn,
  # build-system
  setuptools,
  tabulate,
}:

buildPythonPackage rec {
  pname = "pyseries";
  version = "1.0.26";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Cq+DXt0/6Ncae8OO+kaPuTCxouh0cFPHP+T8tGVXxXo=";
  };

  # no tests in the pypi archive
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    deepdish
    matplotlib
    numpy
    obspy
    pandas
    pyedflib
    scikit-learn
    scipy
    seaborn
    tabulate
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyseries" ];

  pythonRemoveDeps = [
    # sklearn is the old name of the scikit-learn package
    "sklearn"
  ];

  meta = {
    description = "Package for statistical analysis of time-series data";
    homepage = "https://pypi.org/project/pyseries/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
