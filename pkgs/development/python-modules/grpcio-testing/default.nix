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
  pname = "grpcio-testing";
  version = "1.81.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-MjcL3/wM0Jq63pKP2ID5Gb8HCv5dASot4UEkJ7LcGSE=";
    pname = "grpcio_testing";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail '"grpcio>={version}".format(version=grpc_version.VERSION)' '"grpcio"'
  '';

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    grpcio
    protobuf
  ];

  pyproject = true;
  pythonImportsCheck = [ "grpc_testing" ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Testing utilities for gRPC Python";
    homepage = "https://grpc.io/";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
