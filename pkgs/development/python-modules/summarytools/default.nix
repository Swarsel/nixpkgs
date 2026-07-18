{
  lib,
  buildPythonPackage,
  fetchPypi,
  ipython,
  matplotlib,
  numpy,
  pandas,
  setuptools,
}:

buildPythonPackage rec {
  pname = "summarytools";
  version = "0.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-m29ug+JZC4HgMIVopovA/dyR40Z1IcADOiDWKg9mzdc=";
  };

  build-system = [ setuptools ];

  dependencies = [
    ipython
    matplotlib
    numpy
    pandas
  ];

  pyproject = true;
  pythonImportsCheck = [ "summarytools" ];

  meta = {
    description = "Python port of the R summarytools package for summarizing dataframes";
    homepage = "https://github.com/6chaoran/jupyter-summarytools";
    changelog = "https://github.com/6chaoran/jupyter-summarytools/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
