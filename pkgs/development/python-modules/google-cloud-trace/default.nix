{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-api-core,
  google-cloud-testutils,
  mock,
  proto-plus,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "google-cloud-trace";
  version = "1.20.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-9ab5uNpTC3bEUhY7g+UIHBaW8bT2cpDIeLDnNw8ekQo=";
    pname = "google_cloud_trace";
  };

  nativeCheckInputs = [
    google-cloud-testutils
    mock
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    proto-plus
    protobuf
  ]
  ++ google-api-core.optional-dependencies.grpc;

  disabledTests = [
    # Tests require credentials
    "test_batch_write_spans"
    "test_list_traces"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "google.cloud.trace"
    "google.cloud.trace_v1"
    "google.cloud.trace_v2"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Cloud Trace API client library";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-trace";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-trace-v${version}/packages/google-cloud-trace/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
