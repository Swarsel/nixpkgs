{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitUpdater,
  google-api-core,
  google-auth,
  google-geo-type,
  proto-plus,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "google-maps-routing";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "google-cloud-python";
    tag = "google-maps-routing-v${version}";
    hash = "sha256-M/7uDWWz4YCfxa4gyM9BaAo10iyTMvtR2MhNpdFYnis=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    google-auth
    proto-plus
    protobuf
    google-geo-type
  ]
  ++ google-api-core.optional-dependencies.grpc;

  pyproject = true;
  pythonImportsCheck = [ "google.maps.routing_v2" ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  sourceRoot = "${src.name}/packages/google-maps-routing";
  passthru.skipBulkUpdate = true; # picks wrong tag
  passthru.updateScript = gitUpdater { rev-prefix = "google-maps-routing-v"; };

  meta = {
    description = "Google Maps Routing API client library";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-maps-routing";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/${src.tag}/packages/google-maps-routing/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
