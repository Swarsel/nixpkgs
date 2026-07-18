{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-api-core,
  mock,
  proto-plus,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "google-cloud-workflows";
  version = "1.23.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-vo4IpdE0GG2834Z8BbFZrYrH3jtkJbIb76q39PJY1Kg=";
    pname = "google_cloud_workflows";
  };

  nativeCheckInputs = [
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

  pyproject = true;

  pythonImportsCheck = [
    "google.cloud.workflows"
    "google.cloud.workflows_v1"
    "google.cloud.workflows_v1beta"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Python Client for Cloud Workflows";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-workflows";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-workflows-v${finalAttrs.version}/packages/google-cloud-workflows/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
