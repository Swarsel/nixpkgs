{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-api-core,
  google-cloud-testutils,
  mock,
  pandas,
  proto-plus,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "google-cloud-monitoring";
  version = "2.31.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-tMnTUoyGQ9TrS51ojLs8WRS8X2mzFP98XhtHvcBzqa4=";
    pname = "google_cloud_monitoring";
  };

  nativeCheckInputs = [
    google-cloud-testutils
    mock
    pytestCheckHook
    pytest-asyncio
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    proto-plus
    protobuf
  ]
  ++ google-api-core.optional-dependencies.grpc;

  disabledTests = [
    # Test requires credentials
    "test_list_monitored_resource_descriptors"
    # Test requires PRROJECT_ID
    "test_list_alert_policies"
  ];

  optional-dependencies = {
    pandas = [ pandas ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "google.cloud.monitoring"
    "google.cloud.monitoring_v3"
  ];

  pythonRelaxDeps = [ "protobuf" ];

  meta = {
    description = "Stackdriver Monitoring API client library";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-monitoring";
    changelog = "https://github.com/googleapis/google-cloud-python/tree/google-cloud-monitoring-v${finalAttrs.version}/packages/google-cloud-monitoring";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
