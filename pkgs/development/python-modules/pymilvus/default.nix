{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  azure-storage-blob,
  buildPythonPackage,
  # dependencies
  cachetools,
  # build-system
  gitpython,
  grpcio,
  # tests
  grpcio-testing,
  minio,
  # milvus-lite, (unpackaged)
  orjson,
  pandas,
  protobuf,
  pyarrow,
  pytest-asyncio,
  pytest-benchmark,
  pytestCheckHook,
  python-dotenv,
  requests,
  scipy,
  setuptools,
  setuptools-scm,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "pymilvus";
  version = "2.6.12";

  src = fetchFromGitHub {
    owner = "milvus-io";
    repo = "pymilvus";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vjXqGb4HYxa5qHpy8AJBO2G8s8AndJs+zGvxbfvwObY=";
  };

  nativeCheckInputs = [
    grpcio-testing
    pytest-asyncio
    pytest-benchmark
    pytestCheckHook
    scipy
  ]
  ++ finalAttrs.passthru.optional-dependencies.bulk_writer;

  build-system = [
    gitpython
    setuptools
    setuptools-scm
  ];

  dependencies = [
    cachetools
    grpcio
    # milvus-lite
    orjson
    pandas
    protobuf
    python-dotenv
    setuptools
  ];

  disabledTestPaths = [
    # requires running milvus server
    "examples/"

    # tries to write to nix store
    "tests/test_bulk_writer_stage.py"
  ];

  disabledTests = [
    # tries to read .git
    "test_get_commit"

    # requires network access
    "test_deadline_exceeded_shows_connecting_state"

    # mock issue in sandbox
    "test_milvus_client_creates_unbound_alias"
  ];

  optional-dependencies = {
    bulk_writer = [
      azure-storage-blob
      minio
      pyarrow
      requests
      urllib3
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pymilvus" ];

  pythonRelaxDeps = [
    "grpcio"
  ];

  pythonRemoveDeps = [
    "milvus-lite"
  ];

  meta = {
    description = "Python SDK for Milvus";
    homepage = "https://github.com/milvus-io/pymilvus";
    changelog = "https://github.com/milvus-io/pymilvus/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ happysalada ];
  };
})
