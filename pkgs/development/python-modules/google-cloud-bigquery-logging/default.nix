{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-api-core,
  grpc-google-iam-v1,
  mock,
  proto-plus,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "google-cloud-bigquery-logging";
  version = "1.10.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-/uWxsAr51ZW68LWrAXcaTAWwO5zuRo0eA77GLJacWa8=";
    pname = "google_cloud_bigquery_logging";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    grpc-google-iam-v1
    proto-plus
    protobuf
  ]
  ++ google-api-core.optional-dependencies.grpc;

  pyproject = true;

  pythonImportsCheck = [
    "google.cloud.bigquery_logging"
    "google.cloud.bigquery_logging_v1"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Bigquery logging client library";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-bigquery-logging";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-bigquery-logging-v${finalAttrs.version}/packages/google-cloud-bigquery-logging/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
