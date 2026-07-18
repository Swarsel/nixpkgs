{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
}:

buildPythonPackage rec {
  pname = "jsonrpclib-pelix";
  version = "1.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Wx6hTabjcdur7bGr7QqLoc9ZZCg1DNnQGI88bGyO94Q=";
    pname = "jsonrpclib_pelix";
  };

  doCheck = false; # test_suite="tests" in setup.py but no tests in pypi.
  build-system = [ hatchling ];
  pyproject = true;

  meta = {
    description = "JSON RPC client library - Pelix compatible fork";
    homepage = "https://pypi.org/project/jsonrpclib-pelix/";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
