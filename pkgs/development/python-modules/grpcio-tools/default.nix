{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  grpcio,
  protobuf,
  setuptools,
}:

# This package should be updated together with the main grpc package and other
# related python grpc packages.
# nixpkgs-update: no auto update
buildPythonPackage rec {
  pname = "grpcio-tools";
  version = "1.81.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-BzPXc+yoy0YfTyobecZMEj25ZhvkGwgYS4FJeyuZHMs=";
    pname = "grpcio_tools";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "Cython==3.1.1" Cython
  '';

  # no tests in the package
  doCheck = false;

  build-system = [
    cython
    setuptools
  ];

  dependencies = [
    protobuf
    grpcio
    setuptools
  ];

  enableParallelBuilding = true;
  pyproject = true;
  pythonImportsCheck = [ "grpc_tools" ];

  pythonRelaxDeps = [
    "protobuf"
    "grpcio"
  ];

  meta = {
    description = "Protobuf code generator for gRPC";
    homepage = "https://grpc.io/grpc/python/";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
