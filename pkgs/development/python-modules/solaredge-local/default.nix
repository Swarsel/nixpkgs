{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  uplink,
  uplink-protobuf,
}:

buildPythonPackage rec {
  pname = "solaredge-local";
  version = "0.2.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-tGUr4zlMdyJqRyFAs7INiH5rJYPmu7qoaImg4dzW5rk=";
    pname = "solaredge_local";
  };

  # Package has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    uplink
    uplink-protobuf
  ];

  pyproject = true;
  pythonImportsCheck = [ "solaredge_local" ];

  meta = {
    description = "API wrapper to communicate locally with SolarEdge Inverters";
    homepage = "https://github.com/drobtravels/solaredge-local";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
