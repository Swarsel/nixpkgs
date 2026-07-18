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
  pname = "google-cloud-dlp";
  version = "3.38.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-BcdlhL62CzBcE9xRMhp9Aebj7DHd8QXxjVDy+DT3toQ=";
    pname = "google_cloud_dlp";
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
    "test_inspect_content"
    "test_list_dlp_jobs"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "google.cloud.dlp"
    "google.cloud.dlp_v2"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Cloud Data Loss Prevention (DLP) API API client library";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-dlp";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-dlp-v${version}/packages/google-cloud-dlp/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
