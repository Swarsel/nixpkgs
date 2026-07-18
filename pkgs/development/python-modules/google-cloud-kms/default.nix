{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitUpdater,
  google-api-core,
  grpc-google-iam-v1,
  mock,
  proto-plus,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "google-cloud-kms";
  version = "3.14.0";

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "google-cloud-python";
    tag = "google-cloud-kms-v${version}";
    hash = "sha256-ywRS1BfK6s+gcU8QRem0cSnfZq4BUQ2ABNcgnOa01LI=";
  };

  nativeCheckInputs = [
    mock
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    grpc-google-iam-v1
    google-api-core
    proto-plus
    protobuf
  ]
  ++ google-api-core.optional-dependencies.grpc;

  disabledTests = [
    # Disable tests that need credentials
    "test_list_global_key_rings"
    # Tests require PROJECT_ID
    "test_list_ekm_connections"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "google.cloud.kms"
    "google.cloud.kms_v1"
  ];

  pythonRelaxDeps = [ "protobuf" ];
  sourceRoot = "${src.name}/packages/google-cloud-kms";
  # picks the wrong tag
  passthru.skipBulkUpdate = true;

  passthru.updateScript = gitUpdater {
    rev-prefix = "google-cloud-kms-v";
  };

  meta = {
    description = "Cloud Key Management Service (KMS) API API client library";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-kms";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/${src.tag}/packages/google-cloud-kms/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sarahec ];
  };
}
