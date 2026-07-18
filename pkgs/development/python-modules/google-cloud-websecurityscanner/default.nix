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
  pname = "google-cloud-websecurityscanner";
  version = "1.21.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-8/JJV9O7aUxPJIjypmyvaAyOgGD9fvMnYrlmaAvrtcg=";
    pname = "google_cloud_websecurityscanner";
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

  pyproject = true;

  pythonImportsCheck = [
    "google.cloud.websecurityscanner_v1alpha"
    "google.cloud.websecurityscanner_v1beta"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Google Cloud Web Security Scanner API client library";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-websecurityscanner";
    changelog = "https://github.com/googleapis/google-cloud-python/tree/google-cloud-websecurityscanner-v${finalAttrs.version}/packages/google-cloud-websecurityscanner";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
