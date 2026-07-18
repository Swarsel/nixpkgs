{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitUpdater,
  googleapis-common-protos,
  grpcio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "grpc-google-iam-v1";
  version = "0.14.4";

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "google-cloud-python";
    tag = "grpc-google-iam-v1-v${version}";
    hash = "sha256-i2t8qtF2czaP9vgGOUN9AjQ3XhLkk8g05FtXUdk/Vng=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    grpcio
    googleapis-common-protos
  ];

  pyproject = true;

  pytestFlags = [
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [
    "google.iam"
    "google.iam.v1"
  ];

  pythonRelaxDeps = [ "protobuf" ];
  sourceRoot = "${src.name}/packages/grpc-google-iam-v1";

  passthru = {
    skipBulkUpdate = true; # chooses tag for a different project
    updateScript = gitUpdater { rev-prefix = "grpc-google-iam-v1-v"; };
  };

  meta = {
    description = "GRPC library for the google-iam-v1 service";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/grpc-google-iam-v1";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/${src.tag}/packages/grpc-google-iam-v1/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
