{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitUpdater,
  google-api-core,
  google-auth,
  grpc-google-iam-v1,
  grpcio,
  proto-plus,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "google-cloud-storage-control";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "google-cloud-python";
    tag = "google-cloud-storage-control-v${finalAttrs.version}";
    hash = "sha256-M/7uDWWz4YCfxa4gyM9BaAo10iyTMvtR2MhNpdFYnis=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    google-auth
    grpc-google-iam-v1
    grpcio
    proto-plus
    protobuf
  ]
  ++ google-api-core.optional-dependencies.grpc;

  pyproject = true;

  pythonImportsCheck = [
    "google.cloud.storage_control"
    "google.cloud.storage_control_v2"
  ];

  sourceRoot = "${finalAttrs.src.name}/packages/google-cloud-storage-control";

  passthru = {
    # bulk updater selects wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      rev-prefix = "google-cloud-storage-control-v";
    };
  };

  meta = {
    description = "Google Cloud Storage Control API client library";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-storage-control";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/${finalAttrs.src.tag}/packages/google-cloud-storage-control/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
