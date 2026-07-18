{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-api-core,
  opencensus-context,
}:

buildPythonPackage rec {
  pname = "opencensus";
  version = "0.11.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-y++H2Lh3MGSrYOXCoc7Vi7qjim0FLEGuwiSVjOVE7/I=";
  };

  propagatedBuildInputs = [
    google-api-core
    opencensus-context
  ];

  doCheck = false; # No tests in sdist
  format = "setuptools";
  pythonImportsCheck = [ "opencensus.common" ];
  pythonNamespaces = [ "opencensus.common" ];

  meta = {
    description = "Stats collection and distributed tracing framework";
    homepage = "https://github.com/census-instrumentation/opencensus-python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ billhuang ];
  };
}
