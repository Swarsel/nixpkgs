{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-api-core,
  google-cloud-core,
  grpc-google-iam-v1,
  proto-plus,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "google-cloud-resource-manager";
  version = "1.18.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-22ifgAoUxm0EEZan+7i7iq6NyH8owpKeEBpex2axVRI=";
    pname = "google_cloud_resource_manager";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  # Prevent google directory from shadowing google imports
  preCheck = ''
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

  pyproject = true;

  pythonImportsCheck = [
    "google.cloud.resourcemanager"
    "google.cloud.resourcemanager_v3"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Google Cloud Resource Manager API client library";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-resource-manager";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-resource-manager-v${finalAttrs.version}/packages/google-cloud-resource-manager/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
