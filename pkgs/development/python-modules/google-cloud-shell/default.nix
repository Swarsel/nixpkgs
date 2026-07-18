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
  pname = "google-cloud-shell";
  version = "1.16.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-e0RMNqR4jxA+hwlNM2Lyspsh9WKfQRWndZ1oZJMRZoI=";
    pname = "google_cloud_shell";
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
    "google.cloud.shell"
    "google.cloud.shell_v1"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Python Client for Cloud Shell";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-shell";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-shell-v${finalAttrs.version}/packages/google-cloud-shell/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
