{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-api-core,
  google-auth,
  mock,
  proto-plus,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "google-cloud-speech";
  version = "2.40.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-6J5ojkzguSZ1QDi/mS0NDwZcXxw1A7sg5sRtCLY2WPw=";
    pname = "google_cloud_speech";
  };

  nativeCheckInputs = [
    mock
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    google-auth
    proto-plus
    protobuf
  ]
  ++ google-api-core.optional-dependencies.grpc;

  disabledTests = [
    # Test requires project ID
    "test_list_phrase_set"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "google.cloud.speech"
    "google.cloud.speech_v1"
    "google.cloud.speech_v1p1beta1"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Google Cloud Speech API client library";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-speech";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-speech-v${version}/packages/google-cloud-speech/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
