{
  lib,
  buildPythonPackage,
  fetchPypi,
  grpcio,
  protobuf,
  setuptools,
}:

# This package should be updated together with the main grpc package and other
# related python grpc packages.
# nixpkgs-update: no auto update
buildPythonPackage rec {
  pname = "grpcio-reflection";
  version = "1.81.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-UZHbeqbKsbaYGwh5+kT9zdQ7pkTwMBxAuXb4E+tO/wY=";
    pname = "grpcio_reflection";
  };

  # no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    grpcio
    protobuf
  ];

  pyproject = true;
  pythonImportsCheck = [ "grpc_reflection" ];

  pythonRelaxDeps = [
    "grpcio"
    "protobuf"
  ];

  meta = {
    description = "Standard Protobuf Reflection Service for gRPC";
    homepage = "https://pypi.org/project/grpcio-reflection";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
