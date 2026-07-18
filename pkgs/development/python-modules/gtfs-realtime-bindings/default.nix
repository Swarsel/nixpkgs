{
  lib,
  buildPythonPackage,
  fetchPypi,
  protobuf,
  setuptools,
}:

buildPythonPackage rec {
  pname = "gtfs-realtime-bindings";
  version = "2.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-FQfKOWKO6N8tOq44+e7YgdSoKqgkaTDWCLpkKNXKOlY=";
    pname = "gtfs_realtime_bindings";
  };

  # Tests are not shipped, only a tarball for Java is present
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ protobuf ];
  pyproject = true;
  pythonImportsCheck = [ "google.transit" ];

  meta = {
    description = "Python bindings generated from the GTFS Realtime protocol buffer spec";
    homepage = "https://github.com/MobilityData/gtfs-realtime-bindings";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
