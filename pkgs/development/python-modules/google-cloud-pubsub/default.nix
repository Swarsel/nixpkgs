{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-api-core,
  google-cloud-testutils,
  grpc-google-iam-v1,
  grpcio,
  grpcio-status,
  libcst,
  opentelemetry-api,
  opentelemetry-sdk,
  proto-plus,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "google-cloud-pubsub";
  version = "2.39.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-7tZeJfV/lb8+AtltfuFxaIsjkiRx+fIbWpHtkOEoLA8=";
    pname = "google_cloud_pubsub";
  };

  nativeCheckInputs = [
    google-cloud-testutils
    pytestCheckHook
    pytest-asyncio
  ];

  preCheck = ''
    # prevent google directory from shadowing google imports
    rm -r google
  '';

  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    grpc-google-iam-v1
    grpcio
    grpcio-status
    libcst
    opentelemetry-api
    opentelemetry-sdk
    proto-plus
    protobuf
  ]
  ++ google-api-core.optional-dependencies.grpc;

  disabledTestPaths = [
    # Tests in pubsub_v1 attempt to contact pubsub.googleapis.com
    "tests/unit/pubsub_v1"
  ];

  optional-dependencies = {
    libcst = [ libcst ];
  };

  pyproject = true;
  pythonImportsCheck = [ "google.cloud.pubsub" ];
  pythonRelaxDeps = [ "protobuf" ];

  meta = {
    description = "Google Cloud Pub/Sub API client library";
    homepage = "https://github.com/googleapis/python-pubsub";
    changelog = "https://github.com/googleapis/python-pubsub/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "fixup_pubsub_v1_keywords.py";
  };
}
