{
  lib,
  stdenv,
  buildPythonPackage,
  c-ares,
  cython,
  fetchPypi,
  openssl,
  pkg-config,
  protobuf,
  setuptools,
  typing-extensions,
  zlib,
}:

# This package should be updated together with the main grpc package and other
# related python grpc packages.
# nixpkgs-update: no auto update
buildPythonPackage rec {
  pname = "grpcio";
  version = "1.81.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-pazX79Ox/ptOsLyqoVB+7WigrQZ4tlTD97Rk35up3KU=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail cython==3.1.1 cython
  '';

  nativeBuildInputs = [
    cython
    pkg-config
  ];

  buildInputs = [
    c-ares
    openssl
    zlib
  ];

  env = {
    GRPC_BUILD_WITH_BORING_SSL_ASM = "";
    GRPC_PYTHON_BUILD_SYSTEM_CARES = 1;
    GRPC_PYTHON_BUILD_SYSTEM_OPENSSL = 1;
    GRPC_PYTHON_BUILD_SYSTEM_ZLIB = 1;
  };

  preBuild = ''
    export GRPC_PYTHON_BUILD_EXT_COMPILER_JOBS="$NIX_BUILD_CORES"
    if [ -z "$enableParallelBuilding" ]; then
      GRPC_PYTHON_BUILD_EXT_COMPILER_JOBS=1
    fi
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    unset AR
  '';

  # does not contain any tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    protobuf
    typing-extensions
  ];

  enableParallelBuilding = true;
  pyproject = true;
  pythonImportsCheck = [ "grpc" ];

  meta = {
    description = "HTTP/2-based RPC framework";
    homepage = "https://grpc.io/grpc/python/";
    changelog = "https://github.com/grpc/grpc/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
