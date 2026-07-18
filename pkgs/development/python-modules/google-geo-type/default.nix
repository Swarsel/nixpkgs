{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitUpdater,
  google-api-core,
  google-auth,
  proto-plus,
  protobuf,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "google-geo-type";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "google-cloud-python";
    tag = "google-geo-type-v${version}";
    hash = "sha256-M/7uDWWz4YCfxa4gyM9BaAo10iyTMvtR2MhNpdFYnis=";
  };

  nativeCheckInputs = [
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
  pythonImportsCheck = [ "google.geo.type" ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  sourceRoot = "${src.name}/packages/google-geo-type";

  passthru = {
    skipBulkUpdate = true; # chooses tag for a different project
    updateScript = gitUpdater { rev-prefix = "google-geo-type-v"; };
  };

  meta = {
    description = "Google Geo Type API client library";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-geo-type";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/${src.tag}/packages/google-geo-type/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
