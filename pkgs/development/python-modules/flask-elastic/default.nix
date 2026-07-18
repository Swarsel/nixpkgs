{
  lib,
  buildPythonPackage,
  elasticsearch,
  fetchPypi,
  flask,
}:

buildPythonPackage rec {
  pname = "flask-elastic";
  version = "0.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-XwGm/FQbXSV2qbAlHyAbT4DLcQnIseDm1Qqdb5zjE0M=";
    pname = "Flask-Elastic";
  };

  propagatedBuildInputs = [
    flask
    elasticsearch
  ];

  doCheck = false; # no tests
  format = "setuptools";

  meta = {
    description = "Integrates official client for Elasticsearch into Flask";
    homepage = "https://github.com/marceltschoppch/flask-elastic";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.mic92 ];
  };
}
