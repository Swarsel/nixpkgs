{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-api-core,
  protobuf,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "google-cloud-access-context-manager";
  version = "0.6.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-dgJn+6H4voY24qjXwwICfzECYP/4BRxGuLCbl9VGjuA=";
    pname = "google_cloud_access_context_manager";
  };

  # No tests in repo
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    protobuf
  ]
  ++ google-api-core.optional-dependencies.grpc;

  pyproject = true;
  pythonImportsCheck = [ "google.identity.accesscontextmanager" ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Protobufs for Google Access Context Manager";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-access-context-manager";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-access-context-manager-v${finalAttrs.version}/packages/google-cloud-access-context-manager/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ austinbutler ];
  };
})
