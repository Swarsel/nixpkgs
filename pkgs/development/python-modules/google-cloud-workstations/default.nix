{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-api-core,
  google-auth,
  grpc-google-iam-v1,
  mock,
  proto-plus,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "google-cloud-workstations";
  version = "0.8.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-UqFrc09BCap+10CJximc6cymUl8diSW9gxqZbPfn0UY=";
    pname = "google_cloud_workstations";
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
    grpc-google-iam-v1
    proto-plus
    protobuf
  ]
  ++ google-api-core.optional-dependencies.grpc;

  pyproject = true;

  pythonImportsCheck = [
    "google.cloud.workstations"
    "google.cloud.workstations_v1"
    "google.cloud.workstations_v1beta"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Python Client for Cloud Workstations";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-workstations";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-workstations-v${finalAttrs.version}/packages/google-cloud-workstations/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
