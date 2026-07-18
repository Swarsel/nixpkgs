{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # optional dependencies
  crc32c,
  lz4,
  pyperf,
  pytest-mock,
  pytest-timeout,
  # test dependencies
  pytestCheckHook,
  python-snappy,
  pythonAtLeast,
  # build system
  setuptools,
  xxhash,
  zstandard,
}:

buildPythonPackage (finalAttrs: {
  pname = "kafka-python";
  version = "3.0.8";

  src = fetchFromGitHub {
    owner = "dpkp";
    repo = "kafka-python";
    tag = finalAttrs.version;
    hash = "sha256-f/4RcR4vUn0odVdm+YASkqklYFMRHuwlyYln19w/WOs=";
  };

  nativeCheckInputs = [
    pytest-mock
    pytest-timeout
    pytestCheckHook
    xxhash
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  __structuredAttrs = true;
  build-system = [ setuptools ];

  optional-dependencies = {
    benchmarks = [ pyperf ];
    crc32c = [ crc32c ];
    lz4 = [ lz4 ];
    snappy = [ python-snappy ];
    zstd = [ zstandard ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "kafka"
    "kafka.admin"
    "kafka.benchmarks"
    "kafka.cli"
    "kafka.consumer"
    "kafka.coordinator"
    "kafka.metrics"
    "kafka.net"
    "kafka.partitioner"
    "kafka.producer"
    "kafka.protocol"
    "kafka.record"
    "kafka.serializer"
    "kafka.vendor"
  ];

  meta = {
    description = "Pure Python client for Apache Kafka";
    homepage = "https://github.com/dpkp/kafka-python";
    changelog = "https://github.com/dpkp/kafka-python/blob/${finalAttrs.src.tag}/CHANGES.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      de11n
      despsyched
    ];
  };
})
