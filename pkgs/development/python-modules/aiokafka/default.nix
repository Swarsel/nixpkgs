{
  lib,
  fetchFromGitHub,
  async-timeout,
  buildPythonPackage,
  cramjam,
  cython,
  gssapi,
  packaging,
  setuptools,
  typing-extensions,
  zlib,
}:

buildPythonPackage rec {
  pname = "aiokafka";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "aiokafka";
    tag = "v${version}";
    hash = "sha256-xmrNhtyFY+3CJhECIVZRMVx0sZbZ00RLiyZzOdPNNIs=";
  };

  buildInputs = [ zlib ];
  # Checks require running Kafka server
  doCheck = false;

  build-system = [
    cython
    setuptools
  ];

  dependencies = [
    async-timeout
    packaging
    typing-extensions
  ];

  optional-dependencies = {
    all = [
      cramjam
      gssapi
    ];

    gssapi = [ gssapi ];
    lz4 = [ cramjam ];
    snappy = [ cramjam ];
    zstd = [ cramjam ];
  };

  pyproject = true;
  pythonImportsCheck = [ "aiokafka" ];

  meta = {
    description = "Kafka integration with asyncio";
    homepage = "https://aiokafka.readthedocs.org";
    changelog = "https://github.com/aio-libs/aiokafka/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
