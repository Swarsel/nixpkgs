{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  googleapis-common-protos,
  grpcio,
  protobuf,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "clarifai-grpc";
  version = "12.5.1";

  src = fetchFromGitHub {
    owner = "Clarifai";
    repo = "clarifai-python-grpc";
    tag = finalAttrs.version;
    hash = "sha256-CoG2q7Z6Rima3llFm7MIKqNuECgdf895EZNbqEApU0Y=";
  };

  # almost all tests require network access
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    googleapis-common-protos
    grpcio
    protobuf
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "clarifai_grpc" ];

  pythonRelaxDeps = [
    "grpcio"
  ];

  meta = {
    description = "Clarifai gRPC API Client";
    homepage = "https://github.com/Clarifai/clarifai-python-grpc";
    changelog = "https://github.com/Clarifai/clarifai-python-grpc/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ natsukium ];
  };
})
