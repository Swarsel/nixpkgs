{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  grpc,
  nix-update-script,
  protobuf,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "googleapis-common-protos";
  version = "1.73.0";

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "google-cloud-python";
    tag = "googleapis-common-protos-v${finalAttrs.version}";
    hash = "sha256-LrsmLySAOTsECwxa1NaFuyZAjar0Jbg9DHNi6uqYaxk=";
  };

  # does not contain tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    grpc
    protobuf
  ];

  pyproject = true;

  pythonImportsCheck = [
    "google.api"
    "google.logging"
    "google.longrunning"
    "google.rpc"
    "google.type"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  sourceRoot = "${finalAttrs.src.name}/packages/googleapis-common-protos";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "googleapis-common-protos-v([0-9.]+)"
    ];
  };

  meta = {
    description = "Common protobufs used in Google APIs";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/googleapis-common-protos";
    changelog = "https://github.com/googleapis/google-cloud-python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sarahec ];
  };
})
