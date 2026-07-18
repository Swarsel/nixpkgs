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
  pname = "grpcio-channelz";
  version = "1.81.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-V6Gr5QURNJv9iafEJtHbaRmOLJzUcbr2wNVgbDTbmt8=";
    pname = "grpcio_channelz";
  };

  # no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    grpcio
    protobuf
  ];

  pyproject = true;
  pythonImportsCheck = [ "grpc_channelz" ];

  pythonRelaxDeps = [
    "grpcio"
    "protobuf"
  ];

  meta = {
    description = "Channel Level Live Debug Information Service for gRPC";
    homepage = "https://pypi.org/project/grpcio-channelz";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
