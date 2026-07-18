{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  google-api-core,
  google-cloud-access-context-manager,
  google-cloud-org-policy,
  google-cloud-os-config,
  google-cloud-testutils,
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
  pname = "google-cloud-asset";
  version = "4.4.0";

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "google-cloud-python";
    tag = "google-cloud-asset-v${finalAttrs.version}";
    sha256 = "sha256-M/7uDWWz4YCfxa4gyM9BaAo10iyTMvtR2MhNpdFYnis=";
  };

  nativeCheckInputs = [
    google-cloud-testutils
    mock
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    grpc-google-iam-v1
    google-api-core
    google-cloud-access-context-manager
    google-cloud-org-policy
    google-cloud-os-config
    libcst
    proto-plus
    protobuf
  ]
  ++ google-api-core.optional-dependencies.grpc;

  optional-dependencies = {
    libcst = [ libcst ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "google.cloud.asset"
    "google.cloud.asset_v1"
    "google.cloud.asset_v1p1beta1"
    "google.cloud.asset_v1p2beta1"
    "google.cloud.asset_v1p5beta1"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  sourceRoot = "${finalAttrs.src.name}/packages/google-cloud-asset";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regexp"
        "^google-cloud-asset: v([0-9.]+)"
      ];
    };
  };

  meta = {
    description = "Python Client for Google Cloud Asset API";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-asset";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/${finalAttrs.src.tag}/packages/google-cloud-asset/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sarahec ];
  };
})
