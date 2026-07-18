{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  google-api-core,
  google-auth,
  # tests
  google-cloud-testutils,
  grpcio,
  mock,
  proto-plus,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "google-ai-generativelanguage";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "google-cloud-python";
    tag = "google-ai-generativelanguage-v${finalAttrs.version}";
    hash = "sha256-M/7uDWWz4YCfxa4gyM9BaAo10iyTMvtR2MhNpdFYnis=";
  };

  nativeCheckInputs = [
    google-cloud-testutils
    mock
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    google-auth
    grpcio
    proto-plus
    protobuf
  ]
  ++ google-api-core.optional-dependencies.grpc;

  pyproject = true;

  pythonImportsCheck = [
    "google.ai.generativelanguage"
    "google.ai.generativelanguage_v1beta2"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  sourceRoot = "${finalAttrs.src.name}/packages/google-ai-generativelanguage";

  meta = {
    description = "Google Ai Generativelanguage API client library";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-ai-generativelanguage";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/${finalAttrs.src.tag}/packages/google-ai-generativelanguage/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
