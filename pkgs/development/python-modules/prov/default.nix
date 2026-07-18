{
  lib,
  buildPythonPackage,
  fetchPypi,
  lxml,
  networkx,
  pydot,
  python-dateutil,
  rdflib,
}:

buildPythonPackage rec {
  pname = "prov";
  version = "2.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-fQErFk9bu0LhGO2dJXiKsBLQkIK3Iryd1OgRownqV/U=";
  };

  propagatedBuildInputs = [
    lxml
    networkx
    python-dateutil
    rdflib
  ];

  # Multiple tests are out-dated and failing
  doCheck = false;
  nativeCheckInputs = [ pydot ];
  format = "setuptools";
  pythonImportsCheck = [ "prov" ];

  meta = {
    description = "Python library for W3C Provenance Data Model (PROV)";
    homepage = "https://github.com/trungdong/prov";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ashgillman ];
  };
}
