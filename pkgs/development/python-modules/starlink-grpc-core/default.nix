{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  grpcio,
  protobuf,
  setuptools,
  setuptools-scm,
  yagrc,
}:

buildPythonPackage rec {
  pname = "starlink-grpc-core";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "sparky8512";
    repo = "starlink-grpc-tools";
    tag = "v${version}";
    hash = "sha256-+KQ0zzgbqnzeQZXBTxnclJQbRioirK8Ym4EjJSQA3ZE=";
  };

  # no tests
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    grpcio
    protobuf
    yagrc
  ];

  pypaBuildFlags = [ "packaging" ];
  pyproject = true;
  pythonImportsCheck = [ "starlink_grpc" ];

  meta = {
    description = "Core functions for Starlink gRPC communication";
    homepage = "https://github.com/sparky8512/starlink-grpc-tools";
    changelog = "https://github.com/sparky8512/starlink-grpc-tools/releases/tag/v${version}";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
