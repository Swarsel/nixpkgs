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

buildPythonPackage rec {
  pname = "google-cloud-compute";
  version = "1.42.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-CLHbxXWLqlSRCHvO+1dOWdkRUgtxTtp5tOvxy0KdjZg=";
    pname = "google_cloud_compute";
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

  disabledTestPaths = [
    # Disable tests that require credentials
    "tests/system/test_addresses.py"
    "tests/system/test_instance_group.py"
    "tests/system/test_pagination.py"
    "tests/system/test_smoke.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "google.cloud.compute"
    "google.cloud.compute_v1"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "API Client library for Google Cloud Compute";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-compute";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-compute-v${version}/packages/google-cloud-compute/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jpetrucciani ];
  };
}
