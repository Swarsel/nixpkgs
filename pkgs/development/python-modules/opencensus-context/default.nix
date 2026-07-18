{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "opencensus-context";
  version = "0.1.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-oDEIw8ENjIC7Xd9cih8DMWH6YZcqmRf5ubOhhRfwCIw=";
  };

  doCheck = false; # No tests in archive
  format = "setuptools";
  pythonNamespaces = [ "opencensus.common" ];

  meta = {
    description = "OpenCensus Runtime Context";
    homepage = "https://github.com/census-instrumentation/opencensus-python/tree/master/context/opencensus-context";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ billhuang ];
  };
}
