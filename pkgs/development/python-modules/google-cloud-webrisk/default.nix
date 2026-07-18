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

buildPythonPackage (finalAttrs: {
  pname = "google-cloud-webrisk";
  version = "1.22.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-OjJcQDXpbtq4RB8Cev6UgCqvDByOXmoJ306oFlQtryQ=";
    pname = "google_cloud_webrisk";
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

  pyproject = true;

  pythonImportsCheck = [
    "google.cloud.webrisk"
    "google.cloud.webrisk_v1"
    "google.cloud.webrisk_v1beta1"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Python Client for Web Risk";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-webrisk";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-webrisk-v${finalAttrs.version}/packages/google-cloud-webrisk/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
