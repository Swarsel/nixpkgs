{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  certifi,
  # nativeBuildInputs
  cmake,
  # optional-dependencies
  fastavro,
  grpcio,
  # dependencies
  libpulsar,
  pkg-config,
  prometheus-client,
  protobuf,
  pybind11,
  ratelimit,
  # build-system
  setuptools,
  # tests
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pulsar-client";
  version = "3.10.0";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "pulsar-client-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZmuZskkviHantE5vOJd0Di8aqu086G36TQJoEFW2VaY=";
  };

  patches = [
    # Remove TLS bindings removed in libpulsar 4.x
    ./fix-libpulsar-4.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libpulsar
    pybind11
  ];

  preBuild = ''
    make -j$NIX_BUILD_CORES
    make install
    cd ..
  '';

  nativeCheckInputs = [
    unittestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
  ];

  dependencies = [ certifi ];

  optional-dependencies = {
    avro = [ fastavro ];

    functions = [
      # apache-bookkeeper-client
      grpcio
      prometheus-client
      protobuf
      ratelimit
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pulsar" ];

  unittestFlagsArray = [
    "-s"
    "test"
  ];

  meta = {
    description = "Apache Pulsar Python client library";
    homepage = "https://pulsar.apache.org/docs/next/client-libraries-python/";
    changelog = "https://github.com/apache/pulsar-client-python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
