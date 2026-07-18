{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-api-core,
  grpc-google-iam-v1,
  mock,
  proto-plus,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "google-cloud-network-connectivity";
  version = "2.16.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-7MHGRbCsZ86gESY5igxklf3Cr3D51fuGVxnaO9xz+TE=";
    pname = "google_cloud_network_connectivity";
  };

  nativeCheckInputs = [
    mock
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    grpc-google-iam-v1
    proto-plus
    protobuf
  ]
  ++ google-api-core.optional-dependencies.grpc;

  pyproject = true;

  pythonImportsCheck = [
    "google.cloud.networkconnectivity"
    "google.cloud.networkconnectivity_v1"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "API Client library for Google Cloud Network Connectivity Center";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-network-connectivity";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-network-connectivity-v${finalAttrs.version}/packages/google-cloud-network-connectivity/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ aksiksi ];
  };
})
