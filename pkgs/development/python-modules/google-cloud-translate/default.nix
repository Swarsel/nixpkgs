{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-api-core,
  google-cloud-core,
  google-cloud-testutils,
  grpc-google-iam-v1,
  mock,
  proto-plus,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "google-cloud-translate";
  version = "3.27.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-KueO8aqNu17JdnoI6rzjT9p7tFoHumeubg6tjP1flfc=";
    pname = "google_cloud_translate";
  };

  nativeCheckInputs = [
    google-cloud-testutils
    mock
    pytest-asyncio
    pytestCheckHook
  ];

  preCheck = ''
    # prevent shadowing imports
    rm -r google
  '';

  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    google-cloud-core
    grpc-google-iam-v1
    proto-plus
    protobuf
  ]
  ++ google-api-core.optional-dependencies.grpc;

  disabledTests = [
    # Tests require PROJECT_ID
    "test_list_glossaries"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "google.cloud.translate"
    "google.cloud.translate_v2"
    "google.cloud.translate_v3"
    "google.cloud.translate_v3beta1"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Google Cloud Translation API client library";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-translate";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-translate-v${version}/packages/google-cloud-translate/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
