{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-api-core,
  proto-plus,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "google-cloud-language";
  version = "2.21.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-MPDmkVDJckVeJUOaCA97VjDyC9QE3O+KVq5QP5Skvm0=";
    pname = "google_cloud_language";
  };

  nativeCheckInputs = [
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
    "google.cloud.language"
    "google.cloud.language_v1"
    "google.cloud.language_v1beta2"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Google Cloud Natural Language API client library";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-language";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-language-v${finalAttrs.version}/packages/google-cloud-language/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
