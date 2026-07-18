{
  lib,
  buildPythonPackage,
  fetchPypi,
  legacy-cgi,
  lxml,
  numpy,
  pyqt5,
  setuptools,
  six,
  withTreeVisualization ? false,
  withXmlSupport ? false,
}:

buildPythonPackage rec {
  pname = "ete3";
  version = "3.1.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-BqO3+o7ZAYewdqjbvlsbYqzulCAdPG6CL1X0SWAe9vI=";
  };

  doCheck = false; # Tests are (i) not 3.x compatible, (ii) broken under 2.7

  build-system = [
    setuptools
  ];

  dependencies = [
    six
    numpy
    legacy-cgi
  ]
  ++ lib.optional withTreeVisualization pyqt5
  ++ lib.optional withXmlSupport lxml;

  pyproject = true;
  pythonImportsCheck = [ "ete3" ];

  meta = {
    description = "Python framework for the analysis and visualization of trees";
    homepage = "http://etetoolkit.org/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ delehef ];
    mainProgram = "ete3";
  };
}
