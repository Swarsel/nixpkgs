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
  pname = "google-cloud-texttospeech";
  version = "2.37.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-23JjgvOTzrazYALDWr1itTxNjhf8LzHfiwf9D6u+T4s=";
    pname = "google_cloud_texttospeech";
  };

  nativeCheckInputs = [
    mock
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    proto-plus
    protobuf
  ]
  ++ google-api-core.optional-dependencies.grpc;

  disabledTests = [
    # Tests that require credentials
    "test_list_voices"
    "test_synthesize_speech"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "google.cloud.texttospeech"
    "google.cloud.texttospeech_v1"
    "google.cloud.texttospeech_v1beta1"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Google Cloud Text-to-Speech API client library";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-texttospeech";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-texttospeech-v${finalAttrs.version}/packages/google-cloud-texttospeech/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
