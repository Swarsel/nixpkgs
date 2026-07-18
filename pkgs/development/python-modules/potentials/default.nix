{
  lib,
  fetchFromGitHub,
  # dependencies
  bibtexparser,
  buildPythonPackage,
  cdcs,
  datamodeldict,
  fetchPypi,
  habanero,
  ipywidgets,
  lxml,
  matplotlib,
  numpy,
  pandas,
  requests,
  scipy,
  # build-system
  setuptools,
  unidecode,
  xmltodict,
  yabadaba,
}:

buildPythonPackage rec {
  pname = "potentials";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "usnistgov";
    repo = "potentials";
    tag = "v${version}";
    hash = "sha256-R6LGRmi6xeNp81qylXBAVdL62/SN87TvuyRqueQD6DA=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    bibtexparser
    cdcs
    datamodeldict
    habanero
    ipywidgets
    lxml
    matplotlib
    numpy
    pandas
    requests
    scipy
    unidecode
    xmltodict
    yabadaba
  ];

  pyproject = true;
  pythonImportsCheck = [ "potentials" ];

  meta = {
    description = "Python API database tools for accessing the NIST Interatomic Potentials Repository";
    homepage = "https://github.com/usnistgov/potentials";
    changelog = "https://github.com/usnistgov/potentials/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
