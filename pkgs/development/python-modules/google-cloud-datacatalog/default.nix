{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  google-api-core,
  grpc-google-iam-v1,
  libcst,
  mock,
  nix-update-script,
  proto-plus,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "google-cloud-datacatalog";
  version = "3.31.0";

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "google-cloud-python";
    tag = "google-cloud-datacatalog-v${finalAttrs.version}";
    hash = "sha256-M/7uDWWz4YCfxa4gyM9BaAo10iyTMvtR2MhNpdFYnis=";
  };

  nativeCheckInputs = [
    mock
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    grpc-google-iam-v1
    libcst
    proto-plus
    protobuf
  ]
  ++ google-api-core.optional-dependencies.grpc;

  pyproject = true;
  pythonImportsCheck = [ "google.cloud.datacatalog" ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  sourceRoot = "${finalAttrs.src.name}/packages/google-cloud-datacatalog";

  passthru = {
    # bulk updater selects wrong tag
    skipBulkUpdate = true;

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "google-cloud-datacatalog-v([0-9.]+)"
      ];
    };
  };

  meta = {
    description = "Google Cloud Data Catalog API API client library";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-datacatalog";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/${finalAttrs.src.tag}/packages/google-cloud-datacatalog/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sarahec ];
  };
})
