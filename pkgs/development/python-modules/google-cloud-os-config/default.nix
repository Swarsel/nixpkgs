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

buildPythonPackage rec {
  pname = "google-cloud-os-config";
  version = "1.25.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-LgJxfWoNq+j26/e5s36yi19w4zWL18rwzdvPhDswPaE=";
    pname = "google_cloud_os_config";
  };

  nativeCheckInputs = [
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
    # Test requires a project ID
    "test_patch_deployment"
    "test_patch_job"
    "test_list_patch_jobs"
  ];

  pyproject = true;
  pythonImportsCheck = [ "google.cloud.osconfig" ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Google Cloud OS Config API client library";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-os-config";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-os-config-v${version}/packages/google-cloud-os-config/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
